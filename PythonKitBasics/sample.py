import youtube_dl

videoName = "NA"

def hello():
    return "Hello Swift, this is Python"

def swap(a, b):
    a, b = b, a
    return a, b

def downloadVideo(link, path):
    ydl_opts = {
    'format': 'best',
    'writesubtitles' : 'writesubtitles',
    'outtmpl': path + '/%(title)s.%(ext)s'
    }

    with youtube_dl.YoutubeDL(ydl_opts) as ydl:
        info_dict = ydl.extract_info(link, download=False)
        videoName = info_dict.get('title', None) + '.' + info_dict.get('ext', None)
        ydl.download([link])

    return videoName
