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

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Routes

### Songs
- Get 'api/v1/song': returns all the songs in json format
- Get 'api/v1/song/[id]': returns the id, title, duration, image url and artists of the song with the id in the request in json, return 404 if the id is not found
- Post 'api/v1/song': saves a new song with the data received in json format
	- Example:

		```json
		{
		    "title": "I See Fire",
		    "duration_seconds": 300,
		    "image_url":"www.test.test",
		    "artists": "Ed Sheeran"
		}
		```

### Playlists
- Get 'api/v1/playlist': returns all the playlists in json format
- Get 'api/v1/playlist/[id]': returns the id, title, description, image url, creator and privacy of the playlist with the id in the request in json, return 404 if the id is not found
- Post 'api/v1/playlist': saves a new song with the data received in json format
	- Example:

		```json
		{
		    "title": "new playlist",
		    "description": 'test playlist',
		    "image_url":"www.test.test",
		    "creator": "Xavier",
		    "is_private": True
		}
		```
- Post 'api/v1/song-playlist': adds a song to a playlist, returns 400 in case the playlist_id or song_id is not found
	- Example:
		```json
		{
		    "playlist_id": 1,
		    "song_id": '3'
		}
		```