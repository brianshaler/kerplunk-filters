###
# Filter schema
###

module.exports = (mongoose) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId

  FilterSchema = new Schema
    all:
      type: Boolean
      default: -> true
    conditions: [{}]
    actions: [{}]
    order:
      type: Number
      default: -> 0

  FilterSchema.statics.createFilter = (data, next) ->
    Filter = mongoose.model 'Filter'
    obj =
      conditions: []
      actions: []
      all: true

    obj.all = false unless data.all == true

    filter = new Filter obj
    filter.save (err) ->
      return next err if err
      next null, filter

  FilterSchema.pre 'save', (next) ->
    @markModified 'conditions'
    @markModified 'actions'
    next()

  mongoose.model 'Filter', FilterSchema
