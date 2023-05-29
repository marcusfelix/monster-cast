// main.go
package main

import (
	"embed"
	"encoding/json"
	"fmt"
	"log"

	_ "main/migrations"

	"github.com/labstack/echo/v5"
	"github.com/otiai10/opengraph"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
	"mvdan.cc/xurls/v2"
)

//go:embed app/build/web/*
var static embed.FS

func main() {
	app := pocketbase.New()

	// Migrations
	migratecmd.MustRegister(app, app.RootCmd, &migratecmd.Options{
		Automigrate: false, // auto creates migration files when making collection changes
	})

	// Serving embed static files
	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		subFs := echo.MustSubFS(static, "app/build/web")
		e.Router.GET("/*", apis.StaticDirectoryHandler(subFs, false))

		return nil
	})

	// Fetching Open Graph data from message body urls
	app.OnRecordBeforeCreateRequest().Add(func(e *core.RecordCreateEvent) error {
		if e.Record.Collection().Name == "messages" {
			output := xurls.Strict().FindAllString(e.Record.GetString("body"), -1)
			var metadata []any

			for _, url := range output {
				graph, err := fetchOpenGraph(url)
				if err != nil {
					log.Fatal(err)
					return nil
				}
				graph.ToAbsURL()

				image := ""

				if len(graph.Image) > 0 {
					image = graph.Image[0].URL
				}

				json := map[string]string{
					"url":         url,
					"image":       image,
					"title":       graph.Title,
					"description": graph.Description,
				}
				metadata = append(metadata, json)
			}
			out, err := json.Marshal(metadata)
			if err != nil {
				log.Fatal(err)
				return nil
			}

			write := string(out)
			fmt.Print(write)
			e.Record.Set("metadata", write)
		}
		return nil
	})

	// Start Pocketbase
	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}

func fetchOpenGraph(url string) (*opengraph.OpenGraph, error) {
	return opengraph.Fetch(url)
}
