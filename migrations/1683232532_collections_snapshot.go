package migrations

import (
	"encoding/json"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/daos"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/models"
)

func init() {
	m.Register(func(db dbx.Builder) error {
		jsonData := `[
			{
				"id": "_pb_users_auth_",
				"created": "2023-04-15 14:31:20.496Z",
				"updated": "2023-05-04 18:43:25.126Z",
				"name": "users",
				"type": "auth",
				"system": false,
				"schema": [
					{
						"system": false,
						"id": "users_name",
						"name": "name",
						"type": "text",
						"required": false,
						"unique": false,
						"options": {
							"min": null,
							"max": null,
							"pattern": ""
						}
					},
					{
						"system": false,
						"id": "users_avatar",
						"name": "avatar",
						"type": "file",
						"required": false,
						"unique": false,
						"options": {
							"maxSelect": 1,
							"maxSize": 5242880,
							"mimeTypes": [
								"image/jpeg",
								"image/png",
								"image/svg+xml",
								"image/gif",
								"image/webp"
							],
							"thumbs": null
						}
					}
				],
				"indexes": [],
				"listRule": "id = @request.auth.id",
				"viewRule": "@request.auth.id != null",
				"createRule": "",
				"updateRule": "id = @request.auth.id",
				"deleteRule": "id = @request.auth.id",
				"options": {
					"allowEmailAuth": true,
					"allowOAuth2Auth": true,
					"allowUsernameAuth": true,
					"exceptEmailDomains": null,
					"manageRule": null,
					"minPasswordLength": 8,
					"onlyEmailDomains": null,
					"requireEmail": false
				}
			},
			{
				"id": "81z4vgkf4d6y2cw",
				"created": "2023-04-15 14:37:11.725Z",
				"updated": "2023-05-04 19:07:00.501Z",
				"name": "threads",
				"type": "base",
				"system": false,
				"schema": [
					{
						"system": false,
						"id": "nrgytlup",
						"name": "name",
						"type": "text",
						"required": false,
						"unique": false,
						"options": {
							"min": null,
							"max": null,
							"pattern": ""
						}
					},
					{
						"system": false,
						"id": "f0ycwmgu",
						"name": "last_message",
						"type": "text",
						"required": false,
						"unique": false,
						"options": {
							"min": null,
							"max": null,
							"pattern": ""
						}
					},
					{
						"system": false,
						"id": "wveunbol",
						"name": "image",
						"type": "file",
						"required": false,
						"unique": false,
						"options": {
							"maxSelect": 1,
							"maxSize": 5242880,
							"mimeTypes": [
								"image/png",
								"image/jpeg"
							],
							"thumbs": []
						}
					},
					{
						"system": false,
						"id": "c2krssa4",
						"name": "private",
						"type": "bool",
						"required": false,
						"unique": false,
						"options": {}
					},
					{
						"system": false,
						"id": "tepkjfcp",
						"name": "members",
						"type": "relation",
						"required": false,
						"unique": false,
						"options": {
							"collectionId": "_pb_users_auth_",
							"cascadeDelete": false,
							"minSelect": null,
							"maxSelect": null,
							"displayFields": []
						}
					}
				],
				"indexes": [],
				"listRule": "private = false || private = true && members.id ?= @request.auth.id",
				"viewRule": "private = false || private = true && members.id ?= @request.auth.id",
				"createRule": "@request.auth.id != null",
				"updateRule": "private = false || private = true && members.id ?= @request.auth.id",
				"deleteRule": null,
				"options": {}
			},
			{
				"id": "t2lwanotn2tmfhj",
				"created": "2023-04-15 14:39:41.393Z",
				"updated": "2023-05-04 19:04:20.706Z",
				"name": "messages",
				"type": "base",
				"system": false,
				"schema": [
					{
						"system": false,
						"id": "gjvqqwa4",
						"name": "body",
						"type": "text",
						"required": false,
						"unique": false,
						"options": {
							"min": null,
							"max": null,
							"pattern": ""
						}
					},
					{
						"system": false,
						"id": "vmosbvxr",
						"name": "attachments",
						"type": "file",
						"required": false,
						"unique": false,
						"options": {
							"maxSelect": 4,
							"maxSize": 5242880,
							"mimeTypes": [],
							"thumbs": []
						}
					},
					{
						"system": false,
						"id": "fsarhltq",
						"name": "metadata",
						"type": "json",
						"required": false,
						"unique": false,
						"options": {}
					},
					{
						"system": false,
						"id": "w83h6ni9",
						"name": "thread",
						"type": "relation",
						"required": true,
						"unique": false,
						"options": {
							"collectionId": "81z4vgkf4d6y2cw",
							"cascadeDelete": false,
							"minSelect": null,
							"maxSelect": 1,
							"displayFields": []
						}
					},
					{
						"system": false,
						"id": "fpuxzdka",
						"name": "user",
						"type": "relation",
						"required": true,
						"unique": false,
						"options": {
							"collectionId": "_pb_users_auth_",
							"cascadeDelete": true,
							"minSelect": null,
							"maxSelect": 1,
							"displayFields": []
						}
					}
				],
				"indexes": [],
				"listRule": "thread.private = false || thread.private = true && thread.members.id = @request.auth.id",
				"viewRule": "thread.private = false || thread.private = true && thread.members.id = @request.auth.id",
				"createRule": "thread.private = false || thread.private = true && thread.members.id = @request.auth.id",
				"updateRule": "user.id = @request.auth.id",
				"deleteRule": "user.id = @request.auth.id",
				"options": {}
			}
		]`

		collections := []*models.Collection{}
		if err := json.Unmarshal([]byte(jsonData), &collections); err != nil {
			return err
		}

		return daos.New(db).ImportCollections(collections, true, nil)
	}, func(db dbx.Builder) error {
		return nil
	})
}
