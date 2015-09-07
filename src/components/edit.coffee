_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  getInitialState: ->
    conditions: _.map (@props.filter?.conditions ? []), (c, index) ->
      c._id = index
      c
    actions: @props.filter?.actions ? []
    conditionId: @props.filter?.conditions?.length ? 0
    actionId: @props.filter?.actions?.length ? 0

  componentDidMount: ->
    @setState
      all: @props.filter?.all ? true
      showDebug: true

  addCondition: (e) ->
    e.preventDefault()
    conditions = @state.conditions
    allConditions = @props.globals.public.filters.conditions
    firstKey = Object.keys(allConditions)[0]
    conditions.push
      _id: @state.conditionId
      condition: firstKey
    @setState
      conditions: conditions
      conditionId: @state.conditionId + 1

  updateCondition: (index) ->
    (e) =>
      console.log 'update condition', index, e.target.value
      conditions = @state.conditions
      conditions[index].condition = e.target.value
      @setState
        conditions: conditions

  addAction: (e) ->
    e.preventDefault()
    actions = @state.actions
    allActions = @props.globals.public.filters.actions
    firstKey = Object.keys(allActions)[0]
    actions.push
      _id: @state.actionId
      action: firstKey
    @setState
      actions: actions
      actionId: @state.actionId + 1

  updateAction: (index) ->
    (e) =>
      console.log 'update action', index, e.target.value
      actions = @state.actions
      actions[index].action = e.target.value
      @setState
        actions: actions

  toggleAll: (e) ->
    console.log 'toggleAll', e.target?.value, e.currentTarget?.value, @state.all
    @setState
      all: e.target.value == 'true'

  render: ->
    url = '/admin/filters/' + if @props.filter?._id
      "#{@props.filter._id}/edit"
    else
      'new/edit'

    allConditions = @props.globals.public.filters.conditions
    allActions = @props.globals.public.filters.actions

    DOM.section
      className: 'content'
    ,
      DOM.h3 null, 'Edit Filter '# + @props.filter?._id ? 'new'
      DOM.form
        method: 'post'
        action: url
      ,
        DOM.input
          type: 'hidden'
          name: 'filter[_id]'
          value: @props.filter?._id ? 'new'
        DOM.div null,
          'Order:'
          DOM.input
            name: 'filter[order]'
            defaultValue: @props.filter?.order ? 0
        DOM.div null,
          DOM.input
            type: 'radio'
            name: 'filter[all]'
            id: 'filter-all'
            value: 'true'
            onChange: @toggleAll
            checked: (true if @state.all == true)
          DOM.label
            htmlFor: 'filter-all'
          , 'all'
          ' '
          DOM.input
            type: 'radio'
            name: 'filter[all]'
            id: 'filter-any'
            value: 'false'
            onChange: @toggleAll
            checked: (true if @state.all == false)
          DOM.label
            htmlFor: 'filter-any'
          , 'any'
        DOM.h3 null, 'If'
        DOM.div null,
          _.map @state.conditions, (condition, index) =>
            DOM.div
              key: "condition-#{condition._id}"
            ,
              DOM.select
                name: "filter[conditions][#{index}][condition]"
                onChange: @updateCondition index
                defaultValue: condition.condition
              ,
                _.map allConditions, (condition, name) ->
                  DOM.option
                    key: "condition-#{name}-#{index}"
                    value: name
                    selected: (true if condition.condition == name)
                  , condition.description
              if allConditions[condition.condition].parameterRequired
                DOM.input
                  name: "filter[conditions][#{index}][parameter]"
                  defaultValue: condition.parameter
              else
                null
              if index < @state.conditions.length - 1
                DOM.div null,
                  if @state.all
                    'and'
                  else
                    'or'
        DOM.p null,
          DOM.a
            href: '#'
            onClick: @addCondition
          , 'Add Condition'
        DOM.h3 null, 'then'
        DOM.div null,
          _.map @state.actions, (action, index) =>
            DOM.div
              key: "action-#{action._id}"
            ,
              DOM.select
                name: "filter[actions][#{index}][action]"
                onChange: @updateAction index
                defaultValue: action.action
              ,
                _.map allActions, (action, name) ->
                  DOM.option
                    key: "action-#{name}-#{index}"
                    value: name
                    selected: (true if action.action == name)
                  , action.description
              if allActions[action.action].parameterRequired
                DOM.input
                  name: "filter[actions][#{index}][parameter]"
                  defaultValue: action.parameter
              else
                null
        DOM.p null,
          DOM.a
            href: '#'
            onClick: @addAction
          , 'Add Action'
        DOM.p null,
          DOM.input
            type: 'submit'
            className: 'btn btn-success'
            value: 'Save'
        if @state.showDebug
          DOM.div null,
            DOM.pre null, JSON.stringify @state.conditions, null, 2
            DOM.pre null, JSON.stringify @state.actions, null, 2
