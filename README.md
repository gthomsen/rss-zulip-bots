# Overview

Specialized versions of the [Python-based RSS feed to Zulip bot](https://github.com/zulip/python-zulip-api/blob/main/zulip/integrations/rss/rss-bot)
so as to handle different RSS sources.  Currently this supports posts on a
Discourse forum as well as toots from a Mastodon server.

Intended to run as a periodic background task, typically via `cron`.

``` shell
$ ./fetch-all-feeds.sh
```

Individual bots can be run the same way the upstream bot is:

``` shell
$ ./discourse-rss-bot \
    --config zuliprc \
    --stream zulip-stream-name \
    --topic zulip-topic-name \
    --feed-file feed-file
2024-05-20 18:47:35,421: Sent zulips for 3 https://mast.hpc.social/tags/fortran.rss entries
2024-05-20 18:47:36,497: Sent zulips for 20 https://mast.hpc.social/tags/hpc.rss entries
2024-05-20 18:47:36,632: Sent zulips for 0 https://mast.hpc.social/tags/cuda.rss entries
```

# Installation

The Zulip bots are written in Python 3 and depend on the `feedparser` package.

The following creates an environment called `zulip-bots` that can run the bots.
Specify a different environment by adding `-n <environment_name>`, if desired.

``` shell
$ conda env create -f environment.yml
```

Each bot needs a Zulip configuration so that it knows where and how to post to a
Zulip organization.  Update each of the `zuliprc.*` files so that the `key`,
`email`, and `site` variables are set correctly.  Each of these variables'
values can be found in the Bots configuration in Zulip (e.g. Settings -> Bots):

* `key`: The API Key
* `email`: The Bot Email
* `site`: URL of the Zulip organization being posted to

The RSS feeds parsed and posted are specified in each of the `feeds.*` files.
Update these to taste, one URL per line.

The Zulip streams and topics where RSS entries are posted are hardcoded in the
`fetch-all-feeds.sh` script.  Update the `STREAM_*` and `TOPIC_*` variables as
appropriate.

***NOTE:*** The streams used *must* exist, otherwise the Zulip posts will be
silently discarded (although it does generate notification when this happens).

Install the bots' runner script to run via `cron`:

``` shell
$ crontab -e
*/5 * * * * /path/to/zulip-bots/fetch-all-feeds.sh zulip-bots
```

The above runs the bots every five minutes - adjust as necessary.
