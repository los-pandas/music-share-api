# MusicShare-api

API to store share music between streaming services

## Install

```shell
bundle install
```

## Execute

```shell
rackup
```

## Routes

- Get 'api/v1/song': returns all the songs in json format
- Get 'api/v1/song/[id]': returns the id, title, duration, image url and artists of the song with the id in the request in json, return 404 if the id is not found
- Post 'api/v1/song': saves a new song with the data received in json format
	- Example:

		```json
		{
		    "title": "I See Fire",
		    "duration_seconds": 300,
		    "image_url":"www.test.test"
		    "artists": "Ed Sheeran"
		}
		```
