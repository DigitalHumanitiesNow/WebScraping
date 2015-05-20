#!/usr/bin/env python
# encoding: utf-8

import argparse
import feedparser
import csv

parser = argparse.ArgumentParser(description = "Poll a feed and append its " \
                                                "contents to a CSV file.")
parser.add_argument("url", help="URL of the feed to poll")
parser.add_argument("file", help="the CSV file to append to")
args = parser.parse_args()

doc = feedparser.parse(args.url)

# Key is the name of the column. Value is the name of the attribute in the
# parsed feed.
feed_map = {"feed_title": "title",
            "feed_subtitle": "subtitle",
            "feed_url": "link",
            "feed_updated": "updated",
            "feed_id": "id"
            }
entry_map = {"entry_title": "title",
             "entry_link": "link",
             "entry_id": "id",
             "entry_published": "published",
             "entry_updated": "updated",
             "entry_summary": "summary",
             "entry_content": "content"
             }

def append_feed_info(col_name, doc_name, entry_dict, feed):
    try:
        entry_dict[col_name] = feed[doc_name]
    except KeyError:
        entry_dict[col_name] = ""

def append_entry_info(col_name, doc_name, entry_dict, entry):
    # Concatenate the entry content, which is a list of dictionaries
    if col_name == "entry_content":
        concatenated = ""
        try:
          for part in entry["content"]:
              concatenated += part.value + "\n"
          entry_dict[col_name] = concatenated
        except KeyError:
          entry_dict[col_name] = concatenated
        return

    try:
        entry_dict[col_name] = entry[doc_name]
    except KeyError:
        entry_dict[col_name] = ""

entries_holder = []

for entry in doc.entries:
    entry_dict = {}

    for k, v in feed_map.iteritems():
        append_feed_info(k, v, entry_dict, doc.feed)

    for k, v in entry_map.iteritems():
        append_entry_info(k, v, entry_dict, entry)

    entries_holder.append(entry_dict)

with open(args.file, 'w') as csvfile:
    fieldnames = feed_map.keys() + entry_map.keys()
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames,
                            quoting=csv.QUOTE_ALL)
    writer.writeheader()
    for entry in entries_holder:
        writer.writerow(dict((k, v.encode('utf-8')) for k, v in entry.iteritems()))

