
def create_headers(token):
    return {
        'Authorization': 'barear ' + token,
        'Content - Type': 'application / json'
    }


base_url = 'https://%s-api.npe.nexmo.io/beta/'
production_url = 'https://api.nexmo.com/beta/'


def get_url_for_npe(npe_name):
    if npe_name == 'prod':
        return production_url
    return base_url % npe_name


def print_color_json(text):
    import json
    from pygments import highlight, lexers, formatters
    formatted_json = json.dumps(json.loads(text), indent=4)
    colorful_json = highlight(unicode(formatted_json, 'UTF-8'), lexers.JsonLexer(), formatters.TerminalFormatter())
    print(colorful_json)