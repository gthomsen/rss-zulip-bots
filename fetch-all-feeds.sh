#!/bin/bash

# Fetches multiple RSS feeds and posts their contents to a Zulip organization
# via a bot.  Discourse forum posts and Mastodon toots are parsed and
# transformed into a standard format for consumption within Zulip.
#
# NOTE: This squelches the output of each bot so we don't generate spurious
#       emails when run via cron.  On success, this simply provides a summary
#       of actions which is more readily checked by reading the posts in
#       Zulip.
#

if [ $# -ne 1 ]; then
    echo "Usage: $0 <conda_environment>" >&2
    exit 1
fi

ENVIRONMENT_NAME=$1

# We assume all of our scripts and configuration live in the same directory
# as this script.
BOT_ROOT=${0%/*}

# Switch to the environment
. activate ${ENVIRONMENT_NAME}

# Path to the bots.
BOT_DISCOURSE=${BOT_ROOT}/discourse-rss-bot
BOT_MASTODON=${BOT_ROOT}/mastodon-rss-bot

# Path to the bots' Zulip configuration.
ZULIPRC_DISCOURSE=${BOT_ROOT}/zuliprc.discourse
ZULIPRC_MASTODON=${BOT_ROOT}/zuliprc.mastodon

# Path to the RSS feeds to push into Zulip.
FEEDS_DISCOURSE=${BOT_ROOT}/feeds.discourse
FEEDS_MASTODON=${BOT_ROOT}/feeds.mastodon

# Zulip streams to post to.
STREAM_DISCOURSE=bot-test
STREAM_MASTODON=bot-test

# Topics to use within the target streams.
TOPIC_DISCOURSE=discourse-fortran-lang
TOPIC_MASTODON=mastodon

# Discard standard error so we don't get summaries of each RSS entry posted to
# Zulip.  Track the number of failed bots so we're not entirely blind to
# problems.
exec 2>/dev/null
NUMBER_ERRORS=0

# Discourse bot.
./${BOT_DISCOURSE} \
  --config ${ZULIPRC_DISCOURSE} \
  --stream ${STREAM_DISCOURSE} \
  --topic ${TOPIC_DISCOURSE} \
  --feed-file ${FEEDS_DISCOURSE}

if [ $? -ne 0 ]; then
    NUMBER_ERRORS=$((NUMBER_ERRORS + 1))
fi

# Mastodon bot.
./${BOT_MASTODON} \
  --config ${ZULIPRC_MASTODON} \
  --stream ${STREAM_MASTODON} \
  --topic ${TOPIC_MASTODON} \
  --feed-file ${FEEDS_MASTODON}

if [ $? -ne 0 ]; then
    NUMBER_ERRORS=$((NUMBER_ERRORS + 1))
fi

# Let the user know that something went wrong so they can troubleshoot.
if [ ${NUMBER_ERRORS} -gt 0 ]; then
    echo "Some RSS feeds could not be converted into Zulip posts (${NUMBER_ERRORS})!" >&2
    exit 1
fi
