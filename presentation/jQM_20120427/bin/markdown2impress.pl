#!/usr/bin/env perl

use strict;
use Cwd;
use Getopt::Long;
use Data::Section::Simple qw( get_data_section );
use File::Path qw( make_path );
use File::Spec;
use Path::Class;
use Text::Markdown qw( markdown );
use Text::Xslate qw( mark_raw );
use Data::Dumper qw( Dumper );

my %opts = (
    width      => 1200,
    height     => 800,
    max_column => 5,
    outputdir  => getcwd(),
);

GetOptions(
    'width=i'     => \$opts{ width },
    'height=i'    => \$opts{ height },
    'column=i'    => \$opts{ max_column },
    'outputdir=s' => \$opts{ outputdir },
);

my $SectionRe = qr{(.+[\s\t]*\n[-=]+[\s\t]*\n*(?:(?!.+[\s\t]*\n[-=]+[\s\t]*\n*)(?:.|\n))*)};

$opts{ outputdir } = File::Spec->canonpath( $opts{ outputdir } );
output_static_files( $opts{ outputdir } );

my $outputfile = 'index.html';
$outputfile = File::Spec->catfile( $opts{ outputdir }, $outputfile );

my $mdfile = $ARGV[0] or die;
my ($title, $content) = parse_markdown( join '', file( $mdfile )->slurp );
$content =~ s/<code>/<code class="prettyprint">/g;
my $index_html = get_data_section( 'index.html' );
my $tx = Text::Xslate->new;
print mark_raw( $content );
my $output = $tx->render_string( $index_html, {
    content => mark_raw( $content ),
    title => $title,
} );
my $outputfile_fh = file( $outputfile )->open( 'w' ) or die $!;
print $outputfile_fh $output;
close $outputfile_fh;

sub parse_markdown {
    my $md = shift;
    print $md,"00000\n";
    my $content;
    my @sections;
    while ( $md =~ /$SectionRe/g ) {
        print $1,"11111\n";
        push @sections, $1;
    }
    my $bored = 1;
    my $x = 0;
    my $y = 0;
    my $current_column = 0;
    for my $section ( @sections ) {
        my %attrs;
        $attrs{ class } = 'step'; # default
        while ( $section =~ /^<!\-{2,}\s*([^\s]+)\s*\-{2,}>/gm ) {
            my $attr = $1;
            if ( $attr =~ /(.+)="?([^"]+)?"?/ ) {
                $attrs{ $1 } = $attrs{ $1 } ? [ $attrs{ $1 }, $2 ] : $2;
            }
        }
        if ( !defined $attrs{ id } && $x == 0 && $y == 0 ) {
            $attrs{ id } = 'title'; # for first presentation
        }
        unless ( defined $attrs{ 'data-x' } ) {
            $attrs{ 'data-x' } = $x;
            $x += $opts{ width };
        }
        unless ( defined $attrs{ 'data-y' } ) {
            $attrs{ 'data-y' } = $y;
            $current_column++;
            if ( $current_column >= $opts{ max_column } ) {
                $x = 0;
                $y += $opts{ height };
                $current_column = 0;
            }
        }
        my $attrs = join ' ', map {
            if ( ref $attrs{ $_ } eq 'ARRAY' ) {
                sprintf '%s="%s"', $_, join ' ', @{ $attrs{$_} };
            }
            else {
                sprintf '%s="%s"', $_, $attrs{$_};
            }
        } keys %attrs;
        $content .= sprintf <<'HTML', $attrs, markdown( $section, {empty_element_suffix => '>', tab_width => 4, });
<div %s>
%s
</div>
HTML
        ;
        $bored = undef;
    }
    return $title, $content;
}

sub output_static_files {
    my $dir = shift;
    my $impress_js       = get_data_section( 'impress.js' );
    my $impress_demo_css = get_data_section( 'impress.css' );

    my $jsdir = File::Spec->catfile( $dir, 'js' );
    unless ( -d $jsdir ) {
        make_path( $jsdir );
    }

    my $cssdir = File::Spec->catfile( $dir, 'css' );
    unless ( -d $cssdir ) {
        make_path( $cssdir );
    }

    my $jsfile = file( File::Spec->catfile( $jsdir, 'impress.js' ) );
    #unless ( -f $jsfile ) {
        my $jsfh = $jsfile->openw;
        print $jsfh $impress_js;
        $jsfh->close;
    #}

    my $cssfile = file( File::Spec->catfile( $cssdir, 'impress.css' ) );
    #unless ( -f $cssfile ) {
        my $cssfh = $cssfile->openw;
        print $cssfh $impress_demo_css;
        $cssfh->close;
    #}
}

__DATA__

@@ index.html
<!doctype html>
<html lang="ja-JP">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=1024" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title><: $title :></title>
    <link href="http://fonts.googleapis.com/css?family=Open+Sans:regular,semibold,italic,italicsemibold|PT+Sans:400,700,400italic,700italic|PT+Serif:400,700,400italic,700italic" rel="stylesheet" />
    <link href="css/impress.css" rel="stylesheet" />
    <link rel="shortcut icon" href="favicon.png" />
    <script src="src/prettify.js" type="text/javascript"></script>
    <link href="src/prettify.css" rel="stylesheet" type="text/css"/>
</head>
<body class="impress-not-supported" onload="prettyPrint()">
<div class="fallback-message">
    <p>Your browser <b>doesn't support the features required</b> by impress.js, so you are presented with a simplified version of this presentation.</p>
    <p>For the best experience please use the latest <b>Chrome</b>, <b>Safari</b> or <b>Firefox</b> browser.</p>
</div>
<div id="impress">

<: $content :>
    <div id="overview" class="step" data-x="2500" data-y="1500" data-scale="7">
    </div>
</div>
<script src="js/impress.js"></script>
<script>impress().init();</script>
</body>
</html>

@@ impress.js
/**
 * impress.js
 *
 * impress.js is a presentation tool based on the power of CSS3 transforms and transitions
 * in modern browsers and inspired by the idea behind prezi.com.
 *
 *
 * Copyright 2011-2012 Bartek Szopka (@bartaz)
 *
 * Released under the MIT and GPL Licenses.
 *
 * ------------------------------------------------
 *  author:  Bartek Szopka
 *  version: 0.5.3
 *  url:     http://bartaz.github.com/impress.js/
 *  source:  http://github.com/bartaz/impress.js/
 */

/*jshint bitwise:true, curly:true, eqeqeq:true, forin:true, latedef:true, newcap:true,
         noarg:true, noempty:true, undef:true, strict:true, browser:true */

// You are one of those who like to know how thing work inside?
// Let me show you the cogs that make impress.js run...
(function ( document, window ) {
    'use strict';

    // HELPER FUNCTIONS

    // `pfx` is a function that takes a standard CSS property name as a parameter
    // and returns it's prefixed version valid for current browser it runs in.
    // The code is heavily inspired by Modernizr http://www.modernizr.com/
    var pfx = (function () {

        var style = document.createElement('dummy').style,
            prefixes = 'Webkit Moz O ms Khtml'.split(' '),
            memory = {};

        return function ( prop ) {
            if ( typeof memory[ prop ] === "undefined" ) {

                var ucProp  = prop.charAt(0).toUpperCase() + prop.substr(1),
                    props   = (prop + ' ' + prefixes.join(ucProp + ' ') + ucProp).split(' ');

                memory[ prop ] = null;
                for ( var i in props ) {
                    if ( style[ props[i] ] !== undefined ) {
                        memory[ prop ] = props[i];
                        break;
                    }
                }

            }

            return memory[ prop ];
        };

    })();

    // `arraify` takes an array-like object and turns it into real Array
    // to make all the Array.prototype goodness available.
    var arrayify = function ( a ) {
        return [].slice.call( a );
    };

    // `css` function applies the styles given in `props` object to the element
    // given as `el`. It runs all property names through `pfx` function to make
    // sure proper prefixed version of the property is used.
    var css = function ( el, props ) {
        var key, pkey;
        for ( key in props ) {
            if ( props.hasOwnProperty(key) ) {
                pkey = pfx(key);
                if ( pkey !== null ) {
                    el.style[pkey] = props[key];
                }
            }
        }
        return el;
    };

    // `toNumber` takes a value given as `numeric` parameter and tries to turn
    // it into a number. If it is not possible it returns 0 (or other value
    // given as `fallback`).
    var toNumber = function (numeric, fallback) {
        return isNaN(numeric) ? (fallback || 0) : Number(numeric);
    };

    // `byId` returns element with given `id` - you probably have guessed that ;)
    var byId = function ( id ) {
        return document.getElementById(id);
    };

    // `$` returns first element for given CSS `selector` in the `context` of
    // the given element or whole document.
    var $ = function ( selector, context ) {
        context = context || document;
        return context.querySelector(selector);
    };

    // `$$` return an array of elements for given CSS `selector` in the `context` of
    // the given element or whole document.
    var $$ = function ( selector, context ) {
        context = context || document;
        return arrayify( context.querySelectorAll(selector) );
    };

    // `triggerEvent` builds a custom DOM event with given `eventName` and `detail` data
    // and triggers it on element given as `el`.
    var triggerEvent = function (el, eventName, detail) {
        var event = document.createEvent("CustomEvent");
        event.initCustomEvent(eventName, true, true, detail);
        el.dispatchEvent(event);
    };

    // `translate` builds a translate transform string for given data.
    var translate = function ( t ) {
        return " translate3d(" + t.x + "px," + t.y + "px," + t.z + "px) ";
    };

    // `rotate` builds a rotate transform string for given data.
    // By default the rotations are in X Y Z order that can be reverted by passing `true`
    // as second parameter.
    var rotate = function ( r, revert ) {
        var rX = " rotateX(" + r.x + "deg) ",
            rY = " rotateY(" + r.y + "deg) ",
            rZ = " rotateZ(" + r.z + "deg) ";

        return revert ? rZ+rY+rX : rX+rY+rZ;
    };

    // `scale` builds a scale transform string for given data.
    var scale = function ( s ) {
        return " scale(" + s + ") ";
    };

    // `perspective` builds a perspective transform string for given data.
    var perspective = function ( p ) {
        return " perspective(" + p + "px) ";
    };

    // `getElementFromHash` returns an element located by id from hash part of
    // window location.
    var getElementFromHash = function () {
        // get id from url # by removing `#` or `#/` from the beginning,
        // so both "fallback" `#slide-id` and "enhanced" `#/slide-id` will work
        return byId( window.location.hash.replace(/^#\/?/,"") );
    };

    // `computeWindowScale` counts the scale factor between window size and size
    // defined for the presentation in the config.
    var computeWindowScale = function ( config ) {
        var hScale = window.innerHeight / config.height,
            wScale = window.innerWidth / config.width,
            scale = hScale > wScale ? wScale : hScale;

        if (config.maxScale && scale > config.maxScale) {
            scale = config.maxScale;
        }

        if (config.minScale && scale < config.minScale) {
            scale = config.minScale;
        }

        return scale;
    };

    // CHECK SUPPORT
    var body = document.body;

    var ua = navigator.userAgent.toLowerCase();
    var impressSupported =
                          // browser should support CSS 3D transtorms
                           ( pfx("perspective") !== null ) &&

                          // and `classList` and `dataset` APIs
                           ( body.classList ) &&
                           ( body.dataset ) &&

                          // but some mobile devices need to be blacklisted,
                          // because their CSS 3D support or hardware is not
                          // good enough to run impress.js properly, sorry...
                           ( ua.search(/(iphone)|(ipod)|(android)/) === -1 );

    if (!impressSupported) {
        // we can't be sure that `classList` is supported
        body.className += " impress-not-supported ";
    } else {
        body.classList.remove("impress-not-supported");
        body.classList.add("impress-supported");
    }

    // GLOBALS AND DEFAULTS

    // This is were the root elements of all impress.js instances will be kept.
    // Yes, this means you can have more than one instance on a page, but I'm not
    // sure if it makes any sense in practice ;)
    var roots = {};

    // some default config values.
    var defaults = {
        width: 1024,
        height: 768,
        maxScale: 1,
        minScale: 0,

        perspective: 1000,

        transitionDuration: 1000
    };

    // it's just an empty function ... and a useless comment.
    var empty = function () { return false; };

    // IMPRESS.JS API

    // And that's where interesting things will start to happen.
    // It's the core `impress` function that returns the impress.js API
    // for a presentation based on the element with given id ('impress'
    // by default).
    var impress = window.impress = function ( rootId ) {

        // If impress.js is not supported by the browser return a dummy API
        // it may not be a perfect solution but we return early and avoid
        // running code that may use features not implemented in the browser.
        if (!impressSupported) {
            return {
                init: empty,
                goto: empty,
                prev: empty,
                next: empty
            };
        }

        rootId = rootId || "impress";

        // if given root is already initialized just return the API
        if (roots["impress-root-" + rootId]) {
            return roots["impress-root-" + rootId];
        }

        // data of all presentation steps
        var stepsData = {};

        // element of currently active step
        var activeStep = null;

        // current state (position, rotation and scale) of the presentation
        var currentState = null;

        // array of step elements
        var steps = null;

        // configuration options
        var config = null;

        // scale factor of the browser window
        var windowScale = null;

        // root presentation elements
        var root = byId( rootId );
        var canvas = document.createElement("div");

        var initialized = false;

        // STEP EVENTS
        //
        // There are currently two step events triggered by impress.js
        // `impress:stepenter` is triggered when the step is shown on the
        // screen (the transition from the previous one is finished) and
        // `impress:stepleave` is triggered when the step is left (the
        // transition to next step just starts).

        // reference to last entered step
        var lastEntered = null;

        // `onStepEnter` is called whenever the step element is entered
        // but the event is triggered only if the step is different than
        // last entered step.
        var onStepEnter = function (step) {
            if (lastEntered !== step) {
                triggerEvent(step, "impress:stepenter");
                lastEntered = step;
            }
        };

        // `onStepLeave` is called whenever the step element is left
        // but the event is triggered only if the step is the same as
        // last entered step.
        var onStepLeave = function (step) {
            if (lastEntered === step) {
                triggerEvent(step, "impress:stepleave");
                lastEntered = null;
            }
        };

        // `initStep` initializes given step element by reading data from its
        // data attributes and setting correct styles.
        var initStep = function ( el, idx ) {
            var data = el.dataset,
                step = {
                    translate: {
                        x: toNumber(data.x),
                        y: toNumber(data.y),
                        z: toNumber(data.z)
                    },
                    rotate: {
                        x: toNumber(data.rotateX),
                        y: toNumber(data.rotateY),
                        z: toNumber(data.rotateZ || data.rotate)
                    },
                    scale: toNumber(data.scale, 1),
                    el: el
                };

            if ( !el.id ) {
                el.id = "step-" + (idx + 1);
            }

            stepsData["impress-" + el.id] = step;

            css(el, {
                position: "absolute",
                transform: "translate(-50%,-50%)" +
                           translate(step.translate) +
                           rotate(step.rotate) +
                           scale(step.scale),
                transformStyle: "preserve-3d"
            });
        };

        // `init` API function that initializes (and runs) the presentation.
        var init = function () {
            if (initialized) { return; }

            // First we set up the viewport for mobile devices.
            // For some reason iPad goes nuts when it is not done properly.
            var meta = $("meta[name='viewport']") || document.createElement("meta");
            meta.content = "width=device-width, minimum-scale=1, maximum-scale=1, user-scalable=no";
            if (meta.parentNode !== document.head) {
                meta.name = 'viewport';
                document.head.appendChild(meta);
            }

            // initialize configuration object
            var rootData = root.dataset;
            config = {
                width: toNumber( rootData.width, defaults.width ),
                height: toNumber( rootData.height, defaults.height ),
                maxScale: toNumber( rootData.maxScale, defaults.maxScale ),
                minScale: toNumber( rootData.minScale, defaults.minScale ),
                perspective: toNumber( rootData.perspective, defaults.perspective ),
                transitionDuration: toNumber( rootData.transitionDuration, defaults.transitionDuration )
            };

            windowScale = computeWindowScale( config );

            // wrap steps with "canvas" element
            arrayify( root.childNodes ).forEach(function ( el ) {
                canvas.appendChild( el );
            });
            root.appendChild(canvas);

            // set initial styles
            document.documentElement.style.height = "100%";

            css(body, {
                height: "100%",
                overflow: "hidden"
            });

            var rootStyles = {
                position: "absolute",
                transformOrigin: "top left",
                transition: "all 0s ease-in-out",
                transformStyle: "preserve-3d"
            };

            css(root, rootStyles);
            css(root, {
                top: "50%",
                left: "50%",
                transform: perspective( config.perspective/windowScale ) + scale( windowScale )
            });
            css(canvas, rootStyles);

            body.classList.remove("impress-disabled");
            body.classList.add("impress-enabled");

            // get and init steps
            steps = $$(".step", root);
            steps.forEach( initStep );

            // set a default initial state of the canvas
            currentState = {
                translate: { x: 0, y: 0, z: 0 },
                rotate:    { x: 0, y: 0, z: 0 },
                scale:     1
            };

            initialized = true;

            triggerEvent(root, "impress:init", { api: roots[ "impress-root-" + rootId ] });
        };

        // `getStep` is a helper function that returns a step element defined by parameter.
        // If a number is given, step with index given by the number is returned, if a string
        // is given step element with such id is returned, if DOM element is given it is returned
        // if it is a correct step element.
        var getStep = function ( step ) {
            if (typeof step === "number") {
                step = step < 0 ? steps[ steps.length + step] : steps[ step ];
            } else if (typeof step === "string") {
                step = byId(step);
            }
            return (step && step.id && stepsData["impress-" + step.id]) ? step : null;
        };

        // used to reset timeout for `impress:stepenter` event
        var stepEnterTimeout = null;

        // `goto` API function that moves to step given with `el` parameter (by index, id or element),
        // with a transition `duration` optionally given as second parameter.
        var goto = function ( el, duration ) {

            if ( !initialized || !(el = getStep(el)) ) {
                // presentation not initialized or given element is not a step
                return false;
            }

            // Sometimes it's possible to trigger focus on first link with some keyboard action.
            // Browser in such a case tries to scroll the page to make this element visible
            // (even that body overflow is set to hidden) and it breaks our careful positioning.
            //
            // So, as a lousy (and lazy) workaround we will make the page scroll back to the top
            // whenever slide is selected
            //
            // If you are reading this and know any better way to handle it, I'll be glad to hear about it!
            window.scrollTo(0, 0);

            var step = stepsData["impress-" + el.id];

            if ( activeStep ) {
                activeStep.classList.remove("active");
                body.classList.remove("impress-on-" + activeStep.id);
            }
            el.classList.add("active");

            body.classList.add("impress-on-" + el.id);

            // compute target state of the canvas based on given step
            var target = {
                rotate: {
                    x: -step.rotate.x,
                    y: -step.rotate.y,
                    z: -step.rotate.z
                },
                translate: {
                    x: -step.translate.x,
                    y: -step.translate.y,
                    z: -step.translate.z
                },
                scale: 1 / step.scale
            };

            // Check if the transition is zooming in or not.
            //
            // This information is used to alter the transition style:
            // when we are zooming in - we start with move and rotate transition
            // and the scaling is delayed, but when we are zooming out we start
            // with scaling down and move and rotation are delayed.
            var zoomin = target.scale >= currentState.scale;

            duration = toNumber(duration, config.transitionDuration);
            var delay = (duration / 2);

            // if the same step is re-selected, force computing window scaling,
            // because it is likely to be caused by window resize
            if (el === activeStep) {
                windowScale = computeWindowScale(config);
            }

            var targetScale = target.scale * windowScale;

            // trigger leave of currently active element (if it's not the same step again)
            if (activeStep && activeStep !== el) {
                onStepLeave(activeStep);
            }

            // Now we alter transforms of `root` and `canvas` to trigger transitions.
            //
            // And here is why there are two elements: `root` and `canvas` - they are
            // being animated separately:
            // `root` is used for scaling and `canvas` for translate and rotations.
            // Transitions on them are triggered with different delays (to make
            // visually nice and 'natural' looking transitions), so we need to know
            // that both of them are finished.
            css(root, {
                // to keep the perspective look similar for different scales
                // we need to 'scale' the perspective, too
                transform: perspective( config.perspective / targetScale ) + scale( targetScale ),
                transitionDuration: duration + "ms",
                transitionDelay: (zoomin ? delay : 0) + "ms"
            });

            css(canvas, {
                transform: rotate(target.rotate, true) + translate(target.translate),
                transitionDuration: duration + "ms",
                transitionDelay: (zoomin ? 0 : delay) + "ms"
            });

            // Here is a tricky part...
            //
            // If there is no change in scale or no change in rotation and translation, it means there was actually
            // no delay - because there was no transition on `root` or `canvas` elements.
            // We want to trigger `impress:stepenter` event in the correct moment, so here we compare the current
            // and target values to check if delay should be taken into account.
            //
            // I know that this `if` statement looks scary, but it's pretty simple when you know what is going on
            // - it's simply comparing all the values.
            if ( currentState.scale === target.scale ||
                (currentState.rotate.x === target.rotate.x && currentState.rotate.y === target.rotate.y &&
                 currentState.rotate.z === target.rotate.z && currentState.translate.x === target.translate.x &&
                 currentState.translate.y === target.translate.y && currentState.translate.z === target.translate.z) ) {
                delay = 0;
            }

            // store current state
            currentState = target;
            activeStep = el;

            // And here is where we trigger `impress:stepenter` event.
            // We simply set up a timeout to fire it taking transition duration (and possible delay) into account.
            //
            // I really wanted to make it in more elegant way. The `transitionend` event seemed to be the best way
            // to do it, but the fact that I'm using transitions on two separate elements and that the `transitionend`
            // event is only triggered when there was a transition (change in the values) caused some bugs and
            // made the code really complicated, cause I had to handle all the conditions separately. And it still
            // needed a `setTimeout` fallback for the situations when there is no transition at all.
            // So I decided that I'd rather make the code simpler than use shiny new `transitionend`.
            //
            // If you want learn something interesting and see how it was done with `transitionend` go back to
            // version 0.5.2 of impress.js: http://github.com/bartaz/impress.js/blob/0.5.2/js/impress.js
            window.clearTimeout(stepEnterTimeout);
            stepEnterTimeout = window.setTimeout(function() {
                onStepEnter(activeStep);
            }, duration + delay);

            return el;
        };

        // `prev` API function goes to previous step (in document order)
        var prev = function () {
            var prev = steps.indexOf( activeStep ) - 1;
            prev = prev >= 0 ? steps[ prev ] : steps[ steps.length-1 ];

            return goto(prev);
        };

        // `next` API function goes to next step (in document order)
        var next = function () {
            var next = steps.indexOf( activeStep ) + 1;
            next = next < steps.length ? steps[ next ] : steps[ 0 ];

            return goto(next);
        };

        // Adding some useful classes to step elements.
        //
        // All the steps that have not been shown yet are given `future` class.
        // When the step is entered the `future` class is removed and the `present`
        // class is given. When the step is left `present` class is replaced with
        // `past` class.
        //
        // So every step element is always in one of three possible states:
        // `future`, `present` and `past`.
        //
        // There classes can be used in CSS to style different types of steps.
        // For example the `present` class can be used to trigger some custom
        // animations when step is shown.
        root.addEventListener("impress:init", function(){
            // STEP CLASSES
            steps.forEach(function (step) {
                step.classList.add("future");
            });

            root.addEventListener("impress:stepenter", function (event) {
                event.target.classList.remove("past");
                event.target.classList.remove("future");
                event.target.classList.add("present");
            }, false);

            root.addEventListener("impress:stepleave", function (event) {
                event.target.classList.remove("present");
                event.target.classList.add("past");
            }, false);

        }, false);

        // Adding hash change support.
        root.addEventListener("impress:init", function(){

            // last hash detected
            var lastHash = "";

            // `#/step-id` is used instead of `#step-id` to prevent default browser
            // scrolling to element in hash.
            //
            // And it has to be set after animation finishes, because in Chrome it
            // makes transtion laggy.
            // BUG: http://code.google.com/p/chromium/issues/detail?id=62820
            root.addEventListener("impress:stepenter", function (event) {
                window.location.hash = lastHash = "#/" + event.target.id;
            }, false);

            window.addEventListener("hashchange", function () {
                // When the step is entered hash in the location is updated
                // (just few lines above from here), so the hash change is
                // triggered and we would call `goto` again on the same element.
                //
                // To avoid this we store last entered hash and compare.
                if (window.location.hash !== lastHash) {
                    goto( getElementFromHash() );
                }
            }, false);

            // START
            // by selecting step defined in url or first step of the presentation
            goto(getElementFromHash() || steps[0], 0);
        }, false);

        body.classList.add("impress-disabled");

        // store and return API for given impress.js root element
        return (roots[ "impress-root-" + rootId ] = {
            init: init,
            goto: goto,
            next: next,
            prev: prev
        });

    };

    // flag that can be used in JS to check if browser have passed the support test
    impress.supported = impressSupported;

})(document, window);

// NAVIGATION EVENTS

// As you can see this part is separate from the impress.js core code.
// It's because these navigation actions only need what impress.js provides with
// its simple API.
//
// In future I think about moving it to make them optional, move to separate files
// and treat more like a 'plugins'.
(function ( document, window ) {
    'use strict';

    // throttling function calls, by Remy Sharp
    // http://remysharp.com/2010/07/21/throttling-function-calls/
    var throttle = function (fn, delay) {
        var timer = null;
        return function () {
            var context = this, args = arguments;
            clearTimeout(timer);
            timer = setTimeout(function () {
                fn.apply(context, args);
            }, delay);
        };
    };

    // wait for impress.js to be initialized
    document.addEventListener("impress:init", function (event) {
        // Getting API from event data.
        // So you don't event need to know what is the id of the root element
        // or anything. `impress:init` event data gives you everything you
        // need to control the presentation that was just initialized.
        var api = event.detail.api;

        // KEYBOARD NAVIGATION HANDLERS

        // Prevent default keydown action when one of supported key is pressed.
        document.addEventListener("keydown", function ( event ) {
            if ( event.keyCode === 9 || ( event.keyCode >= 32 && event.keyCode <= 34 ) || (event.keyCode >= 37 && event.keyCode <= 40) ) {
                event.preventDefault();
            }
        }, false);

        // Trigger impress action (next or prev) on keyup.

        // Supported keys are:
        // [space] - quite common in presentation software to move forward
        // [up] [right] / [down] [left] - again common and natural addition,
        // [pgdown] / [pgup] - often triggered by remote controllers,
        // [tab] - this one is quite controversial, but the reason it ended up on
        //   this list is quite an interesting story... Remember that strange part
        //   in the impress.js code where window is scrolled to 0,0 on every presentation
        //   step, because sometimes browser scrolls viewport because of the focused element?
        //   Well, the [tab] key by default navigates around focusable elements, so clicking
        //   it very often caused scrolling to focused element and breaking impress.js
        //   positioning. I didn't want to just prevent this default action, so I used [tab]
        //   as another way to moving to next step... And yes, I know that for the sake of
        //   consistency I should add [shift+tab] as opposite action...
        document.addEventListener("keyup", function ( event ) {
            if ( event.keyCode === 9 || ( event.keyCode >= 32 && event.keyCode <= 34 ) || (event.keyCode >= 37 && event.keyCode <= 40) ) {
                switch( event.keyCode ) {
                    case 33: // pg up
                    case 37: // left
                    case 38: // up
                             api.prev();
                             break;
                    case 9:  // tab
                    case 32: // space
                    case 34: // pg down
                    case 39: // right
                    case 40: // down
                             api.next();
                             break;
                }

                event.preventDefault();
            }
        }, false);

        // delegated handler for clicking on the links to presentation steps
        document.addEventListener("click", function ( event ) {
            // event delegation with "bubbling"
            // check if event target (or any of its parents is a link)
            var target = event.target;
            while ( (target.tagName !== "A") &&
                    (target !== document.documentElement) ) {
                target = target.parentNode;
            }

            if ( target.tagName === "A" ) {
                var href = target.getAttribute("href");

                // if it's a link to presentation step, target this step
                if ( href && href[0] === '#' ) {
                    target = document.getElementById( href.slice(1) );
                }
            }

            if ( api.goto(target) ) {
                event.stopImmediatePropagation();
                event.preventDefault();
            }
        }, false);

        // delegated handler for clicking on step elements
        document.addEventListener("click", function ( event ) {
            var target = event.target;
            // find closest step element that is not active
            while ( !(target.classList.contains("step") && !target.classList.contains("active")) &&
                    (target !== document.documentElement) ) {
                target = target.parentNode;
            }

            if ( api.goto(target) ) {
                event.preventDefault();
            }
        }, false);

        // touch handler to detect taps on the left and right side of the screen
        // based on awesome work of @hakimel: https://github.com/hakimel/reveal.js
        document.addEventListener("touchstart", function ( event ) {
            if (event.touches.length === 1) {
                var x = event.touches[0].clientX,
                    width = window.innerWidth * 0.3,
                    result = null;

                if ( x < width ) {
                    result = api.prev();
                } else if ( x > window.innerWidth - width ) {
                    result = api.next();
                }

                if (result) {
                    event.preventDefault();
                }
            }
        }, false);

        // rescale presentation when window is resized
        window.addEventListener("resize", throttle(function () {
            // force going to active step again, to trigger rescaling
            api.goto( document.querySelector(".active"), 500 );
        }, 250), false);

    }, false);

})(document, window);

// THAT'S ALL FOLKS!
//
// Thanks for reading it all.
// Or thanks for scrolling down and reading the last part.
//
// I've learnt a lot when building impress.js and I hope this code and comments
// will help somebody learn at least some part of it.

@@ impress.css
/*
    So you like the style of impress.js demo?
    Or maybe you are just curious how it was done?

    You couldn't find a better place to find out!

    Welcome to the stylesheet impress.js demo presentation.

    Please remember that it is not meant to be a part of impress.js and is
    not required by impress.js.
    I expect that anyone creating a presentation for impress.js would create
    their own set of styles.

    But feel free to read through it and learn how to get the most of what
    impress.js provides.

    And let me be your guide.

    Shall we begin?
*/


/*
    We start with a good ol' reset.
    That's the one by Eric Meyer http://meyerweb.com/eric/tools/css/reset/

    You can probably argue if it is needed here, or not, but for sure it
    doesn't do any harm and gives us a fresh start.
*/

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
    margin: 0;
    padding: 0;
    border: 0;
    font-size: 100%;
    font: inherit;
    vertical-align: baseline;
}

h1 {
    margin-bottom:20px;
}

h2 {
    font-size:130%;
}

code {
    border-left: 1px solid #CCC;
    border-right: 1px solid #CCC;
    background: rgba(255,  255,  255,  0.5);
    display: block;
    box-shadow: 1px 0px 1px rgba(255, 255, 255, 1) inset;
    font-size: 92%;
    padding:0 15px 0;
}

pre {
    font-size: 65%;
}

div.gist-meta {
    font-size: 25%;
}

div.step p code:first-child {
    margin-top:20px;
    border-top:1px solid #ccc;
    box-shadow: 1px 1px 1px rgba(255, 255, 255, 1) inset;
    padding:15px 15px 0;
}

div.step p code:last-child {
    padding:0px 15px 15px;
}

/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
    display: block;
}
body {
    line-height: 1;
}
ol, ul {
    /*
    list-style: none;
    */
}
li {
    margin-left: 50px;
    font-size: 80%;
}
blockquote, q {
    quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
    content: '';
    content: none;
}

table {
    border-collapse: collapse;
    border-spacing: 0;
}

/*
    Now here is when interesting things start to appear.

    We set up <body> styles with default font and nice gradient in the background.
    And yes, there is a lot of repetition there because of -prefixes but we don't
    want to leave anybody behind.
*/
body {
    font-family: 'PT Sans', sans-serif;
    min-height: 740px;

    background: rgb(215, 215, 215);
    background: -webkit-gradient(radial, 50% 50%, 0, 50% 50%, 500, from(rgb(240, 240, 240)), to(rgb(190, 190, 190)));
    background: -webkit-radial-gradient(rgb(240, 240, 240), rgb(190, 190, 190));
    background:    -moz-radial-gradient(rgb(240, 240, 240), rgb(190, 190, 190));
    background:     -ms-radial-gradient(rgb(240, 240, 240), rgb(190, 190, 190));
    background:      -o-radial-gradient(rgb(240, 240, 240), rgb(190, 190, 190));
    background:         radial-gradient(rgb(240, 240, 240), rgb(190, 190, 190));
}

/*
    Now let's bring some text styles back ...
*/
b, strong { font-weight: bold }
i, em { font-style: italic }

/*
    ... and give links a nice look.
*/
a {
    color: #FF4456;
    /*
    padding: 0 0.1em;
    background: rgba(255,255,255,0.5);
    */
    text-shadow: -1px -1px 2px rgba(100,100,100,0.9);
    border-radius: 0.2em;

    -webkit-transition: 0.5s;
    -moz-transition:    0.5s;
    -ms-transition:     0.5s;
    -o-transition:      0.5s;
    transition:         0.5s;
}

a:hover,
a:focus {
    /*
    background: rgba(255,255,255,1);
    */
    text-shadow: -1px -1px 2px rgba(100,100,100,0.5);
}

/*
    Because the main point behind the impress.js demo is to demo impress.js
    we display a fallback message for users with browsers that don't support
    all the features required by it.

    All of the content will be still fully accessible for them, but I want
    them to know that they are missing something - that's what the demo is
    about, isn't it?

    And then we hide the message, when support is detected in the browser.
*/

.fallback-message {
    font-family: sans-serif;
    line-height: 1.3;

    width: 780px;
    padding: 10px 10px 0;
    margin: 20px auto;

    border: 1px solid #E4C652;
    border-radius: 10px;
    background: #EEDC94;
}

.fallback-message p {
    margin-bottom: 10px;
}

.impress-supported .fallback-message {
    display: none;
}

/*
    Now let's style the presentation steps.

    We start with basics to make sure it displays correctly in everywhere ...
*/

.step {
    position: relative;
    width: 900px;
    padding: 40px;
    margin: 20px auto;

    -webkit-box-sizing: border-box;
    -moz-box-sizing:    border-box;
    -ms-box-sizing:     border-box;
    -o-box-sizing:      border-box;
    box-sizing:         border-box;

    /*font-family: 'PT Serif', georgia, serif;*/
    font-family: 'Open Sans', Arial, sans-serif;
    font-size: 36px;
    line-height: 1.5;
}

.step h1{
    font-size: 80px;
}

/*
    ... and we enhance the styles for impress.js.

    Basically we remove the margin and make inactive steps a little bit transparent.
*/
.impress-enabled .step {
    margin: 0;
    opacity: 0.3;

    -webkit-transition: opacity 1s;
    -moz-transition:    opacity 1s;
    -ms-transition:     opacity 1s;
    -o-transition:      opacity 1s;
    transition:         opacity 1s;
}

.impress-enabled .step.active { opacity: 1 }

/*
    These 'slide' step styles were heavily inspired by HTML5 Slides:
    http://html5slides.googlecode.com/svn/trunk/styles.css

    ;)

    They cover everything what you see on first three steps of the demo.
*/
.slide-title {
    display: block;

    width: 900px;
    height: 700px;
    padding: 40px 60px;

    /*
    background-color: white;
    border: 1px solid rgba(0, 0, 0, .3);
    border-radius: 10px;
    box-shadow: 0 2px 6px rgba(0, 0, 0, .1);
    */

    color: rgb(102, 102, 102);
    text-shadow: 0 2px 2px rgba(0, 0, 0, .1);

    font-family: 'Open Sans', Arial, sans-serif;
    font-size: 30px;
    line-height: 36px;
    letter-spacing: -1px;
}

.slide-title q {
    /display: block;
    font-size: 50px;
    line-height: 72px;

    margin-top: 100px;
}

.slide-title q strong {
    white-space: nowrap;
}

.slide-main q {
    font-size: 80px;
}

.slide {
    display: block;

    width: 900px;
    height: 700px;
    padding: 40px 60px;

    /*
    background-color: white;
    border: 1px solid rgba(0, 0, 0, .3);
    border-radius: 10px;
    box-shadow: 0 2px 6px rgba(0, 0, 0, .1);
    */

    color: rgb(102, 102, 102);
    text-shadow: 0 2px 2px rgba(0, 0, 0, .1);

    font-family: 'Open Sans', Arial, sans-serif;
    font-size: 30px;
    line-height: 40px;
}

.slide q {
    display: block;
    font-size: 50px;
    line-height: 72px;

    margin-top: 0px;
    margin-bottom: 20px;
}

.slide q strong {
    white-space: nowrap;
}


/*
    And now we start to style each step separately.

    I agree that this may be not the most efficient, object-oriented and
    scalable way of styling, but most of steps have quite a custom look
    and typography tricks here and there, so they had to be styles separately.

    First is the title step with a big <h1> (no room for padding) and some
    3D positioning along Z axis.
*/

#title {
    padding: 0;
}

#title .try {
    font-size: 64px;
    position: absolute;
    top: -0.5em;
    left: 1.5em;

    -webkit-transform: translateZ(20px);
    -moz-transform:    translateZ(20px);
    -ms-transform:     translateZ(20px);
    -o-transform:      translateZ(20px);
    transform:         translateZ(20px);
}

#title h1 {
    font-size: 100px;

    -webkit-transform: translateZ(50px);
    -moz-transform:    translateZ(50px);
    -ms-transform:     translateZ(50px);
    -o-transform:      translateZ(50px);
    transform:         translateZ(50px);
    margin-bottom:20px;
}

#title .footnote {
    font-size: 32px;
}

/*
    Second step is nothing special, just a text with a link, so it doesn't need
    any special styling.

    Let's move to 'big thoughts' with centered text and custom font sizes.
*/
#big {
    width: 600px;
    text-align: center;
    font-size: 60px;
    line-height: 1;
}

#big b {
    display: block;
    font-size: 250px;
    line-height: 250px;
}

#big .thoughts {
    font-size: 90px;
    line-height: 150px;
}

/*
    'Tiny ideas' just need some tiny styling.
*/
#tiny {
    width: 500px;
    text-align: center;
}

/*
    This step has some animated text ...
*/
#ing { width: 500px }

/*
    ... so we define display to `inline-block` to enable transforms and
    transition duration to 0.5s ...
*/
#ing b {
    display: inline-block;
    -webkit-transition: 0.5s;
    -moz-transition:    0.5s;
    -ms-transition:     0.5s;
    -o-transition:      0.5s;
    transition:         0.5s;
}

/*
    ... and we want 'positioning` word to move up a bit when the step gets
    `present` class ...
*/
#ing.present .positioning {
    -webkit-transform: translateY(-10px);
    -moz-transform:    translateY(-10px);
    -ms-transform:     translateY(-10px);
    -o-transform:      translateY(-10px);
    transform:         translateY(-10px);
}

/*
    ... 'rotating' to rotate quater of a second later ...
*/
#ing.present .rotating {
    -webkit-transform: rotate(-10deg);
    -moz-transform:    rotate(-10deg);
    -ms-transform:     rotate(-10deg);
    -o-transform:      rotate(-10deg);
    transform:         rotate(-10deg);

    -webkit-transition-delay: 0.25s;
    -moz-transition-delay:    0.25s;
    -ms-transition-delay:     0.25s;
    -o-transition-delay:      0.25s;
    transition-delay:         0.25s;
}

/*
    ... and 'scaling' to scale down after another quater of a second.
*/
#ing.present .scaling {
    -webkit-transform: scale(0.7);
    -moz-transform:    scale(0.7);
    -ms-transform:     scale(0.7);
    -o-transform:      scale(0.7);
    transform:         scale(0.7);

    -webkit-transition-delay: 0.5s;
    -moz-transition-delay:    0.5s;
    -ms-transition-delay:     0.5s;
    -o-transition-delay:      0.5s;
    transition-delay:         0.5s;
}

/*
    The 'imagination' step is again some boring font-sizing.
*/

#imagination {
    width: 600px;
}

#imagination .imagination {
    font-size: 78px;
}

/*
    There is nothing really special about 'use the source, Luke' step, too,
    except maybe of the Yoda background.

    As you can see below I've 'hard-coded' it in data URL.
    That's not the best way to serve images, but because that's just this one
    I decided it will be OK to have it this way.

    Just make sure you don't blindly copy this approach.
*/
#source {
    width: 700px;
    padding-bottom: 300px;

    /* Yoda Icon :: Pixel Art from Star Wars http://www.pixeljoint.com/pixelart/1423.htm */
    background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARgAAAEYCAMAAACwUBm+AAAAAXNSR0IArs4c6QAAAKtQTFRFsAAAvbWSLUUrLEQqY1s8UYJMqJ1vNTEgOiIdIzYhjIFVLhsXZ6lgSEIsP2U8JhcCVzMsSXZEgXdOO145XJdWOl03LzAYMk4vSXNExr+hwcuxRTs1Qmk+RW9Am49eFRANQz4pUoNMQWc+OSMDTz0wLBsCNVMxa2NBOyUDUoNNSnlEWo9VRGxAVzYFl6tXCggHbLNmMUIcHhwTXkk5f3VNRT8wUT8xAAAACQocRBWFFwAAAAF0Uk5TAEDm2GYAAAPCSURBVHja7d3JctNAFIZRMwRCCGEmzPM8z/D+T8bu/ptbXXJFdij5fMt2Wuo+2UgqxVmtttq5WVotLzBgwIABAwYMGDCn0qVqbo69psPqVpWx+1XG5iaavF8wYMCAAQMGDBgwi4DJ6Y6qkxB1HNlcN3a92gbR5P2CAQMGDBgwYMCAWSxMlrU+UY5yu2l9okfV4bAxUVbf7TJnAwMGDBgwYMCAAbMLMHeqbGR82Zy+VR1Ht81nVca6R+UdTLaU24Ruzd3qM/e4yjnAgAEDBgwYMGDA7AJMd1l/3NRdVGcj3eX/2WEhCmDGxnM7yqygu8XIPjJj8iN/MGDAgAEDBgwYMAuDGb8q0RGlLCHLv1t9qDKWn3vdNHVuEI6HPaxO9Jo3GDBgwIABAwYMmIXBdC9ShGgMk+XnkXUeuGcsP/e1+lhNnZsL/G5Vs3OAAQMGDBgwYMCAWSxMR3SzOmraG5atdy9wZKzb+vg16qyqe2FltbnAgAEDBgwYMGDALAxmTJSuN3WA76rnVca6GTnemGN1WoEBAwYMGDBgwIBZGMxUomy4+xO899V4LAg5Xnc2MGDAgAEDBgwYMGA218Wq+2K1LDqvY9xZu8zN8fICdM6btYABAwYMGDBgwIABMzfH0+pGU5afze2tXebmeAfVz+p8BQYMGDBgwIABAwbMPBzZ+oWmfJrln1273FhkbHzee9WWbw7AgAEDBgwYMGDALAKm43hcdctKgblcPamOhuXnXlY5Xs6bsW4FGyQCAwYMGDBgwIABswiYMceZKgvMo+h8mrHLTdn676rj+FEFoTtHd8MwOxEYMGDAgAEDBgyYRcBM5UhXqiymW3R3c9ARhWO/OmjqfjVZy+xEYMCAAQMGDBgwYBYG073OnCV0RFNhMhaOa9WfKmOB6XjHMN1tQmaAAQMGDBgwYMCA2VWY7vXjz1U4croAzgPztwIDBgwYMGDAgAEDZhswh035NBw59Dww3RgYMGDAgAEDBgwYMJuD6f4tXT7NUqfCdBvZLkxXdgQGDBgwYMCAAQNmt2DGj8WzwAfV/w7T/aq7mxwwYMCAAQMGDBgwuwqTOo7uTwTngflSzQ3TdaJvAwEDBgwYMGDAgAED5gSvgbyo5oHZ4Pc+gwEDBgwYMGDAgAEzhOm+5G0qTGaAAQMGDBgwYMCAAXNaMOcnls3tNwWm+zRzp54NDBgwYMCAAQMGDJh5YNL36k1TLuGvVq+qnKMbS5n7tulT9asCAwYMGDBgwIABA2ZumKuztLnjgQEDBgwYMGDAgNl5mH/4/ltKA6vBNAAAAABJRU5ErkJggg==);
    background-position: bottom right;
    background-repeat: no-repeat;
}

#source q {
    font-size: 60px;
}

/*
    And the "it's in 3D" step again brings some 3D typography - just for fun.

    Because we want to position <span> elements in 3D we set transform-style to
    `preserve-3d` on the paragraph.
    It is not needed by webkit browsers, but it is in Firefox. It's hard to say
    which behaviour is correct as 3D transforms spec is not very clear about it.
*/
#its-in-3d p {
    -webkit-transform-style: preserve-3d;
    -moz-transform-style:    preserve-3d; /* Y U need this Firefox?! */
    -ms-transform-style:     preserve-3d;
    -o-transform-style:      preserve-3d;
    transform-style:         preserve-3d;
}

/*
    Below we position each word separately along Z axis and we want it to transition
    to default position in 0.5s when the step gets `present` class.

    Quite a simple idea, but lot's of styles and prefixes.
*/
#its-in-3d span,
#its-in-3d b {
    display: inline-block;
    -webkit-transform: translateZ(40px);
    -moz-transform:    translateZ(40px);
    -ms-transform:     translateZ(40px);
    -o-transform:      translateZ(40px);
     transform:        translateZ(40px);

    -webkit-transition: 0.5s;
    -moz-transition:    0.5s;
    -ms-transition:     0.5s;
    -o-transition:      0.5s;
    transition:         0.5s;
}

#its-in-3d .have {
    -webkit-transform: translateZ(-40px);
    -moz-transform:    translateZ(-40px);
    -ms-transform:     translateZ(-40px);
    -o-transform:      translateZ(-40px);
    transform:         translateZ(-40px);
}

#its-in-3d .you {
    -webkit-transform: translateZ(20px);
    -moz-transform:    translateZ(20px);
    -ms-transform:     translateZ(20px);
    -o-transform:      translateZ(20px);
    transform:         translateZ(20px);
}

#its-in-3d .noticed {
    -webkit-transform: translateZ(-40px);
    -moz-transform:    translateZ(-40px);
    -ms-transform:     translateZ(-40px);
    -o-transform:      translateZ(-40px);
    transform:         translateZ(-40px);
}

#its-in-3d .its {
    -webkit-transform: translateZ(60px);
    -moz-transform:    translateZ(60px);
    -ms-transform:     translateZ(60px);
    -o-transform:      translateZ(60px);
    transform:         translateZ(60px);
}

#its-in-3d .in {
    -webkit-transform: translateZ(-10px);
    -moz-transform:    translateZ(-10px);
    -ms-transform:     translateZ(-10px);
    -o-transform:      translateZ(-10px);
    transform:         translateZ(-10px);
}

#its-in-3d .footnote {
    font-size: 32px;

    -webkit-transform: translateZ(-10px);
    -moz-transform:    translateZ(-10px);
    -ms-transform:     translateZ(-10px);
    -o-transform:      translateZ(-10px);
    transform:         translateZ(-10px);
}

#its-in-3d.present span,
#its-in-3d.present b {
    -webkit-transform: translateZ(0px);
    -moz-transform:    translateZ(0px);
    -ms-transform:     translateZ(0px);
    -o-transform:      translateZ(0px);
    transform:         translateZ(0px);
}

/*
    The last step is an overview.
    There is no content in it, so we make sure it's not visible because we want
    to be able to click on other steps.

*/
#overview { display: none }

/*
    We also make other steps visible and give them a pointer cursor using the
    `impress-on-` class.
*/
.impress-on-overview .step {
    opacity: 1;
    cursor: pointer;
}


/*
    Now, when we have all the steps styled let's give users a hint how to navigate
    around the presentation.

    The best way to do this would be to use JavaScript, show a delayed hint for a
    first time users, then hide it and store a status in cookie or localStorage...

    But I wanted to have some CSS fun and avoid additional scripting...

    Let me explain it first, so maybe the transition magic will be more readable
    when you read the code.

    First of all I wanted the hint to appear only when user is idle for a while.
    You can't detect the 'idle' state in CSS, but I delayed a appearing of the
    hint by 5s using transition-delay.

    You also can't detect in CSS if the user is a first-time visitor, so I had to
    make an assumption that I'll only show the hint on the first step. And when
    the step is changed hide the hint, because I can assume that user already
    knows how to navigate.

    To summarize it - hint is shown when the user is on the first step for longer
    than 5 seconds.

    The other problem I had was caused by the fact that I wanted the hint to fade
    in and out. It can be easily achieved by transitioning the opacity property.
    But that also meant that the hint was always on the screen, even if totally
    transparent. It covered part of the screen and you couldn't correctly clicked
    through it.
    Unfortunately you cannot transition between display `block` and `none` in pure
    CSS, so I needed a way to not only fade out the hint but also move it out of
    the screen.

    I solved this problem by positioning the hint below the bottom of the screen
    with CSS transform and moving it up to show it. But I also didn't want this move
    to be visible. I wanted the hint only to fade in and out visually, so I delayed
    the fade in transition, so it starts when the hint is already in its correct
    position on the screen.

    I know, it sounds complicated ... maybe it would be easier with the code?
*/

.hint {
    /*
        We hide the hint until presentation is started and from browsers not supporting
        impress.js, as they will have a linear scrollable view ...
    */
    display: none;

    /*
        ... and give it some fixed position and nice styles.
    */
    position: fixed;
    left: 0;
    right: 0;
    bottom: 200px;

    background: rgba(0,0,0,0.5);
    color: #EEE;
    text-align: center;

    font-size: 50px;
    padding: 20px;

    z-index: 100;

    /*
        By default we don't want the hint to be visible, so we make it transparent ...
    */
    opacity: 0;

    /*
        ... and position it below the bottom of the screen (relative to it's fixed position)
    */
    -webkit-transform: translateY(400px);
    -moz-transform:    translateY(400px);
    -ms-transform:     translateY(400px);
    -o-transform:      translateY(400px);
    transform:         translateY(400px);

    /*
        Now let's imagine that the hint is visible and we want to fade it out and move out
        of the screen.

        So we define the transition on the opacity property with 1s duration and another
        transition on transform property delayed by 1s so it will happen after the fade out
        on opacity finished.

        This way user will not see the hint moving down.
    */
    -webkit-transition: opacity 1s, -webkit-transform 0.5s 1s;
    -moz-transition:    opacity 1s,    -moz-transform 0.5s 1s;
    -ms-transition:     opacity 1s,     -ms-transform 0.5s 1s;
    -o-transition:      opacity 1s,      -o-transform 0.5s 1s;
    transition:         opacity 1s,         transform 0.5s 1s;
}

/*
    Now we 'enable' the hint when presentation is initialized ...
*/
.impress-enabled .hint { display: block }

/*
    ... and we will show it when the first step (with id 'bored') is active.
*/
.impress-on-bored .hint {
    /*
        We remove the transparency and position the hint in its default fixed
        position.
    */
    opacity: 1;

    -webkit-transform: translateY(0px);
    -moz-transform:    translateY(0px);
    -ms-transform:     translateY(0px);
    -o-transform:      translateY(0px);
    transform:         translateY(0px);

    /*
        Now for fade in transition we have the oposite situation from the one
        above.

        First after 4.5s delay we animate the transform property to move the hint
        into its correct position and after that we fade it in with opacity
        transition.
    */
    -webkit-transition: opacity 1s 5s, -webkit-transform 0.5s 4.5s;
    -moz-transition:    opacity 1s 5s,    -moz-transform 0.5s 4.5s;
    -ms-transition:     opacity 1s 5s,     -ms-transform 0.5s 4.5s;
    -o-transition:      opacity 1s 5s,      -o-transform 0.5s 4.5s;
    transition:         opacity 1s 5s,         transform 0.5s 4.5s;
}

/*
    And as the last thing there is a workaround for quite strange bug.
    It happens a lot in Chrome. I don't remember if I've seen it in Firefox.

    Sometimes the element positioned in 3D (especially when it's moved back
    along Z axis) is not clickable, because it falls 'behind' the <body>
    element.

    To prevent this, I decided to make <body> non clickable by setting
    pointer-events property to `none` value.
    Value if this property is inherited, so to make everything else clickable
    I bring it back on the #impress element.

    If you want to know more about `pointer-events` here are some docs:
    https://developer.mozilla.org/en/CSS/pointer-events

    There is one very important thing to notice about this workaround - it makes
    everything 'unclickable' except what's in #impress element.

    So use it wisely ... or don't use at all.
*/
.impress-enabled          { pointer-events: none }
.impress-enabled #impress { pointer-events: auto }

/*
    There is one funny thing I just realized.

    Thanks to this workaround above everything except #impress element is invisible
    for click events. That means that the hint element is also not clickable.
    So basically all of this transforms and delayed transitions trickery was probably
    not needed at all...

    But it was fun to learn about it, wasn't it?
*/

/*
    That's all I have for you in this file.
    Thanks for reading. I hope you enjoyed it at least as much as I enjoyed writing it
    for you.
*/

__END__
