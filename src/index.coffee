_ = require 'lodash'
Promise = require 'when'

FilterSchema = require './models/Filter'

module.exports = (System) ->
  Filter = System.registerModel 'Filter', FilterSchema

  allFiltersPromise = null
  getAllFilters = ->
    return allFiltersPromise if allFiltersPromise?
    mpromise = Filter
    .where {}
    .sort
      order: 1
    .find()
    allFiltersPromise = Promise mpromise

  runFilter = (filter, item) ->
    Promise.all _.map filter.conditions, (condition) ->
      data =
        item: item
        match: false
        parameter: condition.parameter
      System.do "filters.conditions.#{condition.condition}", data
      .catch (err) ->
        console.log 'WARN', err?.message ? err?.stack ? err
        data
    .then (results) ->
      hit = _.find results, (result) -> result.match == true
      miss = _.find results, (result) -> result.match == false
      if filter.all
        match = !miss
      else
        match = !!hit
      if match
        Promise.all _.map filter.actions, (action) ->
          data =
            item: item
            parameter: action.parameter
          System.do "filters.actions.#{action.action}", data
          .catch (err) ->
            console.log 'WARN', err?.message ? err?.stack ? err
            data
      else
        null
    .catch (err) ->
      console.log 'filter failed', err?.stack ? err

  preSave = (item) ->
    getAllFilters()
    .then (filters) ->
      promise = Promise.resolve()
      for filter in filters
        do (filter) ->
          promise = promise.then ->
            runFilter filter, item
      promise.then -> item
    .catch (err) ->
      console.log 'preSave filter failed', err
  preSave.precedence = 10

  getFilter = (id) ->
    return Promise.resolve new Filter() if id == 'new'
    mpromise = Filter
    .where
      _id: id
    .findOne()
    Promise mpromise

  routes:
    admin:
      '/admin/filters': 'list'
      '/admin/filters/create': 'create'
      '/admin/filters/:id/edit': 'edit'

  handlers:
    list: (req, res, next) ->
      Filter
      .where {}
      .sort
        order: 1
      .find (err, filters) ->
        return next err if err
        data =
          filters: filters
        res.render 'list', data
    create: 'create'
    edit: (req, res, next) ->
      # console.log 'edit'
      id = req.body?.filter?._id ? req.params.id
      getFilter id
      .then (filter) ->
        data =
          filter: filter
        unless req.body?.filter?._id
          return res.render 'edit', data
        filter.conditions = req.body.filter.conditions
        filter.actions = req.body.filter.actions
        filter.all = req.body.filter.all
        filter.order = parseInt req.body.filter.order
        filter.save (err) ->
          return next err if err
          allFiltersPromise = null
          getAllFilters()
          postInit()
          if id == 'new'
            return res.redirect "/admin/filters/#{filter._id}/edit"
          data.title = 'Edit Filter'
          res.render 'edit', data

  globals:
    public:
      filters:
        conditions: {}
        actions: {}
      nav:
        Admin:
          Filters: '/admin/filters'

  events:
    activityItem:
      save:
        pre: preSave
