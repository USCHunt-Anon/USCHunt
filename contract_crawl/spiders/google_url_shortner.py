import json
import urllib.parse
import urllib.request

class GooglException (Exception):
    
    def shortenURL (self,url_to_shorten):
        """
        Given a URL, return a goo.gl shortened URL
        Arguments
        ---------
            url_to_shorten : string
                The URL you want to shorten
        Returns
        -------
            Shortened goo.gl URL string
        Raises
        ------
            GooglException
                If something goes wrong with the HTTP request
        """

        # The goo.gl API URL
        api_url = 'https://www.googleapis.com/urlshortener/v1/url'
        # Construct our JSON dictionary
        data = json.JSONEncoder().encode({'longUrl': url_to_shorten})
        # Encode to UTF-8 for sending
        data = data.encode('utf-8')
        # HTTP header
        headers = {"Content-Type": "application/json"}
        # Construct the request
        request = urllib.request.Request(api_url, data=data, headers=headers)

        # Make the request and get the response to read from
        try:
            response = urllib.request.urlopen(request)
            success = True
        # If a HTTPError occurs, we will be reading from the error instead
        except urllib.error.HTTPError as err:
            response = err
            success = False
        # Read the response object, decode from utf-8 and convert from JSON
        finally:
            data = json.loads(response.read().decode('utf8'))

        # Return our shortened URL
        if success:
            print('shorten url is ', data['id'])
            return data
        # Or raise an Exception
        else:
            raise GooglException(data['error']['message'])