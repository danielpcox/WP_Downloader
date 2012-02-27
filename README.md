WP Downloader
=============

Thor script (and legacy my old vanilla Ruby script) for downloading the 'Washington Post' and stitching the individual PDFs together

Tasks:
  thor wp:clean                  # Removes all but today's paper from the local paper repository
  thor wp:download               # Downloads and assembles the 'Washington Post.'
  thor wp:help [TASK]            # Describe available tasks or one specific task
  thor wp:view [SECTION_LETTER]  # Views a downloaded 'Washington Post' section

Downloading
-----------

> Usage:
>   thor wp:download
> 
> Options:
>   [--date=YYYY-MM-DD]         # date of paper to download (older than 2 weeks unavailable by WP policy)
>                               # Default: 2012-02-27
>   [--location=/path/to/repo]  # path to local paper repository
>                               # Default: ~/.washingtonpost/
>   [--omit=A,B,...]            # sections to omit
>                               # Default: D
> 
> Downloads and assembles the 'Washington Post.'

Viewing
-------

> Usage:
>   thor wp:view [SECTION_LETTER]
> 
> Options:
>   [--viewer=VIEWER]
>                               # Default: evince
>   [--location=/path/to/repo]  # path to local paper repository
>                               # Default: ~/.washingtonpost/
>   [--date=YYYY-MM-DD]         # date of paper to view
>                               # Default: 2012-02-27
> 
> Views a downloaded 'Washington Post' section

Cleaning
--------

> Usage:
>   thor wp:clean
> 
> Options:
>   [--location=/path/to/repo]  # path to local paper repository
>                               # Default: ~/.washingtonpost/
> 
> Removes all but today's paper from the local paper repository
