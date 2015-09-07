_ = require 'lodash'
React = require 'react'

{DOM} = React

ShowFilter = require './showFilter'

module.exports = React.createFactory React.createClass
  render: ->
    DOM.section
      className: 'content'
    ,
      DOM.h3 null, 'Filters'
      DOM.div
        className: 'clearfix'
      ,
        DOM.a
          onClick: @props.pushState
          href: '/admin/filters/create'
          className: 'btn btn-success'
        , 'create new filter'
      DOM.div
        className: 'clearfix'
      ,
        _.map @props.filters, (filter) =>
          ShowFilter _.extend {}, @props,
            key: "filter-#{filter._id}"
            filter: filter
      DOM.div
        className: 'clearfix'
      ,
        DOM.a
          onClick: @props.pushState
          href: '/admin/filters/create'
          className: 'btn btn-success'
        , 'create new filter'
