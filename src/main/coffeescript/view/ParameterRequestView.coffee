class ParameterRequestView extends Backbone.View
  initialize: ->
    Handlebars.registerHelper 'isArray',
      (param, opts) ->
        if param.type.toLowerCase() == 'array' || param.allowMultiple
          opts.fn(@)
        else
          opts.inverse(@)
          
  render: ->
    type = @model.type || @model.dataType

    if typeof type is 'undefined'
      schema = @model.schema
      if schema and schema['$ref']
        ref = schema['$ref']
        if ref.indexOf('#/definitions/') is 0
          type = ref.substring('#/definitions/'.length)
        else
          type = ref

    @model.type = type
    @model.paramType = @model.in || @model.paramType
    @model.isBody = true if @model.paramType == 'body' or @model.in == 'body'
    @model.isFile = true if type and type.toLowerCase() == 'file'
    @model.default = (@model.default || @model.defaultValue)

    if@model.allowableValues
      @model.isList = true

    template = @template()
    

    signatureModel =
      sampleJSON: @model.sampleJSON
      isParam: true
      signature: @model.signature

    if @model.sampleJSON
      $(@el).html(template(@model))
      signatureView = new SignatureRequestView({model: signatureModel})
      $('.model-signature2', $(@el)).append signatureView.render().el
   

    isParam = false

    if @model.isBody
      isParam = true

    contentTypeModel =
      isParam: isParam

    contentTypeModel.consumes = @model.consumes

    if isParam
      parameterContentTypeView = new ParameterContentTypeView({model: contentTypeModel})
      $('.parameter-content-type', $(@el)).append parameterContentTypeView.render().el

    else
      responseContentTypeView = new ResponseContentTypeView({model: contentTypeModel})
      $('.response-content-type', $(@el)).append responseContentTypeView.render().el

    @

  # Return an appropriate template based on if the parameter is a list, readonly, required
  template: ->
   
    Handlebars.templates.param_show
    
