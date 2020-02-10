# brodcastify_archive

Small ruby script to automate grabbing all the archives of a broadcastify feed you own per date and combine them together into a single mp3 file.

**Notes**:

- Minimum File Size: Currently it skips adding any archive files that have a file size smaller than 75 kB, this become an optional argument in the future to allow adjustment.
- Overlaps: You may occasionally notice small repeating sections of audio, this is because of the way broadcastify creates the archive files that commonly include overlaps at the start of new files.

## Setup

You will need to be running Linux and have [Ruby installed](https://www.ruby-lang.org/en/documentation/installation/). 

Install packages for working with mp3s (Ubuntu/Debian):

```bash
sudo apt-get install mp3wrap
sudo apt-get install id3v2
```

Install required Ruby gems

```bash
gem install faraday
gem install oj
gem install down
```

## Usage

Options:

- -f Feed ID *required*
- -d Date in YYYY-MM-DD format *required*
- -s Short name of your feed *required*
- -n Extended name of your feed *required*
- -u Broadcastify username *required*
- -p Broadcastify password *required*

Example:

```bash
ruby broadcastify.rb -f 11111 -d 2020-02-09 -s "My Feed Short Name" -n "My Feed Extended Name" -u username -p password
```

Output:

Will output a single mp3 to the archives folder named as the feed shortname and date.