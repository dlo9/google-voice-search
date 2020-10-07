# Google Voice Search
## Overview
Google Voice Search scrapes Google Voice for all available numbers, and then searches those numbers for interesting patterns.

## Requirements
- [Docker](https://docs.docker.com/get-docker/)

## Usage
1. Add your voice.google.com cookies to [`scripts/vars.sh` line 12](scripts/vars.sh#L12)
2. Run `docker-compose run google-voice-search`

If you receive an error like `Failed to connect to www.google.com port 443: Operation timed out`, then Google is throttling your requests -- try running the script later, or use a loop:
```sh
while ! docker-compose run google-voice-search; do
	sleep 600 # 10 minutes
done
```

## Resources
- [Inspiration](http://privacylog.blogspot.com/2009/08/full-google-hack.html)
