_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    conditions = _ @props.filter.conditions
    allConditions = @props.globals.public.filters.conditions
    allActions = @props.globals.public.filters.actions

    DOM.section
      className: 'col-lg-4 col-md-6 admin-block'
    ,
      DOM.div
        className: 'box box-info admin-panel'
      ,
        DOM.div
          className: 'box-body admin-panel-content'
          style:
            padding: '0.8em 1.6em'
        ,
          'If '
          _.map @props.filter.conditions, (condition, index) =>
            DOM.span
              key: "filtercnd-#{@props.filter._id}-#{index}"
            ,
              DOM.strong null,
                allConditions[condition.condition]?.description
                if condition.parameter?
                  " \"#{condition.parameter}\""
                else
                  null
              if index < @props.filter.conditions.length - 1
                DOM.span null,
                  if @props.filter.all
                    ' and '
                  else
                    ' or '
          ' then '
          _.map @props.filter.actions, (action, index) =>
            DOM.span
              key: "filteract-#{@props.filter._id}-#{index}"
            ,
              DOM.strong null,
                allActions[action.action]?.description
                if action.parameter?
                  " \"#{action.parameter}\""
                else
                  null
              if index < @props.filter.actions.length - 1
                ', '
              else
                null
          DOM.div
            className: 'clearfix'
          ,
            DOM.a
              onClick: @props.pushState
              href: "/admin/filters/#{@props.filter._id}/edit"
              className: 'btn btn-default'
            , 'edit'
