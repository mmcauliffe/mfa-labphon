import requests_html

URL_TEMPLATE = "https://anaconda.org/conda-forge/montreal-forced-aligner/files?page={page}"

num_pages = 9

if __name__ == '__main__':

    download_count = 0
    session = requests_html.HTMLSession()

    for page in range(1, num_pages+1):
        request = session.get(
            URL_TEMPLATE.format(page=page), timeout=10
        )
        table = request.html.find('form#fileForm', first=True)
        for row in table.find("tr"):
            cells = row.find('td')
            if len(cells) != 7:
                continue
            download_count += int(cells[-2].text)
    print(download_count)
