`import Ember from 'ember'`

VEFigureItemAdapter = Ember.Object.extend

  figure: null
  component: null

  # instance of 'tahi-editor-extensions/form/form-node'
  # which conains two form-entries for 'title' and 'caption'
  node: null
  propertyNodes: null
  cachedValues: null

  observedProperties: ['title', 'caption']

  registerBindings: ( ->
    figure = @get('figure')
    node = @get('node')
    titleNode = null
    captionNode = null
    node.traverse( (node) ->
      if node.type == 'textInput' and node.getPropertyName() == 'title'
        titleNode = node
      else if node.type == 'textInput' and node.getPropertyName() == 'caption'
        captionNode = node
    )
    if not titleNode or not captionNode
      console.error('Could not find title and caption node...')

    @propertyNodes =
      title: titleNode
      caption: captionNode
    @cachedValues =
      title: figure.get('title')
      caption: figure.get('caption')
  ).on('init')


  connect: ->
    # only title and caption can be changed via 'VisualEditor'
    # The image is handled emberly
    figure = @get('figure')
    for propertyName in @observedProperties
      @propertyNodes[propertyName].connect @,
        "change": @propertyEdited
    return @

  disconnect: ->
    figure = @get('figure')
    for propertyName in @observedProperties
      @propertyNodes[propertyName].disconnect @
    return @

  loadFromModel: ->
    figure = @get('figure')
    console.log('##### loading data from figure', figure.get('id'))
    for propertyName in @observedProperties
      console.log('##### %s: %s', propertyName, figure.get(propertyName))
      @updatePropertyNode propertyName, figure.get(propertyName)

  propertyEdited: (propertyName, newValue) ->
    figure = @get('figure')
    oldValue = figure.get(propertyName)
    if oldValue != newValue
      @cachedValues[propertyName] = newValue
      figure.set(propertyName, newValue)
      # console.log('FigureItemAdapter: updated %s. saving...', propertyName)
      @get('component').send('saveFigure')

  # Note: model changes are not handled here
  #   as this dialog can only be opened when editing the paper, thus the paper is locked
  #   TODO: is it so, that figures are also locked then?

`export default VEFigureItemAdapter`
