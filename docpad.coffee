# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON

path = require('path')

productionBasePath = "/~gbrander/2013-06-future-themes";
localBasePath = '';

identity = (thing) -> thing

escapeRegExp = (str) ->
  str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

prependBasePath = (fragment) ->
  """Method eventually attached to templateData object."""
  return path.join(@site.url, fragment)

makeMapPrepend = (prestring) ->
  """Create a prepending mapper function"""
  (string) ->
    prestring + string

asArray = (thing) ->
  """Box `thing` as an array unless already an array"""
  if (thing instanceof Array) then thing else if thing? then [thing] else []

items = (object) ->
  """For an object, get an array of 2-arrays containing key and value for every
  property of the object.
  Only considers own iterable properties."""
  keys = Object.keys(object)
  keys.map((key) -> [key, object[key]])

replaceStringViaPair = (string, pair) ->
  string.replace(pair[0], pair[1])

replaceAll = (strings, replacements) ->
  strings = asArray(strings)
  replacements = asArray(replacements)
  strings.map((string) -> replacements.reduce(replaceStringViaPair, string))

replaceAllTokens = (strings) ->
  tokens = [
    ['@site.url', @site.url]
    ['<site_url>', @site.url]
  ]
  replaceAll(strings, tokens)

searcher = (property, matching) ->
  """Create a property matching function for `filter`."""
  (object) ->
    object[property].search(matching) isnt -1

negatedSearcher = (property, matching) ->
  s = searcher(property, matching)
  (object) ->
    not s(object)

matcher = (value, mapper) ->
  mapper = mapper or identity
  (thing) ->
    thing = mapper(thing)
    thing is value

compareByFilename = (a, b) ->
  """See https://github.com/bevry/docpad/blob/master/src/lib/models/file.coffee
  < and > can be used for alphanumeric sorting strings in JavaScript?!?!
  """
  if a.filename > b.filename then 1 else if a.filename < b.filename then -1 else 0

compareByDate = (a, b) ->
  timestampA = new Date(a.date).valueOf()
  timestampB = new Date(b.date).valueOf()
  if timestampA < timestampB then 1 else if timestampA > timestampB then -1 else 0

getById = (array, id) ->
  array.filter((object) -> object.id == id).pop()

getAdjacent = (array, thing, offset = 1) ->
  startIndex = array.indexOf(thing)
  offsetIndex = startIndex + offset
  adjacent = array[offsetIndex]
  if adjacent then adjacent else null

getAdjacentById = (array, id, offset = 1) ->
  object = getById(array, id)
  getAdjacent(array, object, offset)

isntUrlIndex = negatedSearcher('url', 'index.html')
isUrlIndex = searcher('url', 'index.html')

getDocumentSiblingsSortedByFilenameIndexFirst = (document) ->
  matchSiblingByUrl = matcher(path.dirname(document.url), (document) -> path.dirname(document.url))
  json = @getCollection('html').toJSON().filter(matchSiblingByUrl)
  indexes = json.filter(isUrlIndex)
  sortedPages = json.filter(isntUrlIndex).sort(compareByFilename)
  indexes.concat(sortedPages)

classname = (classnamestrings...) ->
  classesReducer = (accumulated, classname) ->
    accumulated = if typeof classname is 'string' then accumulated.concat(classname.trim().split(' ')) else accumulated
  classnamestrings.reduce(classesReducer, []).join(' ')

STYLES = [
  '/vendor/normalize.css'
  '/assets/basic.css'
]

SCRIPTS = [
  '/assets/artboard.js'
]

docpadConfig = {

  # =================================
  # Template Data
  # These are variables that will be accessible via our templates
  # To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

  templateData:

    # Specify some site properties
    site:
      # The production url of our website
      url: localBasePath

      # Here are some old site urls that you would like to redirect from
      oldUrls: [
      ]

      # The default title of our website
      title: "Future Themes"

      # The website description (for SEO)
      description: """
        Future themes work
        """

      # The website keywords (for SEO) separated by commas
      keywords: """
        """

      # The website's styles
      styles: STYLES.map(makeMapPrepend(localBasePath))

      # The website's scripts
      scripts: SCRIPTS.map(makeMapPrepend(localBasePath))


    # -----------------------------
    # Helper Functions

    # Get the prepared site/document title
    # Often we would like to specify particular formatting to our page's title
    # we can apply that formatting here
    getPreparedTitle: ->
      # if we have a document title, then we should use that and suffix the site's title onto it
      if @document.title
        "#{@document.title} | #{@site.title}"
      # if our document does not have it's own title, then we should just use the site's title
      else
        @site.title

    # Get the prepared site/document description
    getPreparedDescription: ->
      # if we have a document description, then we should use that, otherwise use the site's description
      @document.description or @site.description

    # Get the prepared site/document keywords
    getPreparedKeywords: ->
      # Merge the document keywords with the site keywords
      @site.keywords.concat(@document.keywords or []).join(', ')

    prependBasePath: prependBasePath
    compareByDate: compareByDate
    compareByFilename: compareByFilename
    searcher: searcher
    negatedSearcher: negatedSearcher
    replaceAll: replaceAll
    replaceAllTokens: replaceAllTokens
    getDocumentSiblingsSortedByFilenameIndexFirst: getDocumentSiblingsSortedByFilenameIndexFirst
    getAdjacentById: getAdjacentById,
    classname: classname

  # =================================
  # DocPad Events

  # Here we can define handlers for events that DocPad fires
  # You can find a full listing of events on the DocPad Wiki
  events:

    # Server Extend
    # Used to add our own custom routes to the server before the docpad routes are added
    serverExtend: (opts) ->
      # Extract the server from the options
      {server} = opts
      docpad = @docpad

      # As we are now running in an event,
      # ensure we are using the latest copy of the docpad configuraiton
      # and fetch our urls from it
      latestConfig = docpad.getConfig()
      oldUrls = latestConfig.templateData.site.oldUrls or []
      newUrl = latestConfig.templateData.site.url

      # Redirect any requests accessing one of our sites oldUrls to the new site url
      server.use (req,res,next) ->
        if req.headers.host in oldUrls
          res.redirect(newUrl+req.url, 301)
        else
          next()

  environments:
    production:
      templateData:
        site:
          url: "/~gbrander/2013-06-future-themes"
          styles: STYLES.map(makeMapPrepend(productionBasePath))
          scripts: SCRIPTS.map(makeMapPrepend(productionBasePath))
}

# Export our DocPad Configuration
module.exports = docpadConfig
