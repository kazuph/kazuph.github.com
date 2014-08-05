package main

import (
	"bytes"
	"fmt"
	"github.com/russross/blackfriday"
	"html/template"
	"io/ioutil"
	"strings"
)

// Page template
type Page struct {
	Title string
	Body  string
}

func main() {
	templateByte, _ := ioutil.ReadFile("template.tmpl")
	templateText := string(templateByte)

	markdownByte, _ := ioutil.ReadFile("README.md")
	markdownText := string(markdownByte)

	page := &Page{Title: "ISUCONとリアルISUCONへの挑戦を支えた技術", Body: markdownText}

	tmpl := template.Must(template.New("index.html").Funcs(template.FuncMap{"markDown": markDowner}).Parse(templateText))

	var html bytes.Buffer
	tmpl.ExecuteTemplate(&html, "index.html", page)
	ioutil.WriteFile("index.html", []byte(html.String()), 0644)
}

func markDowner(args ...interface{}) string {
	s := blackfriday.MarkdownCommon([]byte(fmt.Sprintf("%s", args...)))
	return setSection(string(s))
}

func setSection(s string) string {
	s = strings.Replace(s, "<h1>", "</section><section><h1>", -1)
	s = strings.Replace(s, "<h2>", "</section><section><h2>", -1)
	s = strings.Replace(s, "<h3>", "</section><section><h3>", -1)
	s = strings.Replace(s, "</section>", "", 1)
	s = strings.Replace(s, "&amp;#34;", "\"", -1)
	s = strings.Replace(s, "&amp;#39;", "'", -1)
	s += "</section>"
	return s
}
