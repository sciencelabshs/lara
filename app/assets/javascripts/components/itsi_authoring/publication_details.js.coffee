{div, ul, li, span, a} = React.DOM

POLL_INTERVAL = 5000

modulejs.define 'components/itsi_authoring/publication_details',
->
  React.createClass

    getInitialState: ->
      last_publication_hash: @props.publicationDetails.last_publication_hash
      latest_publication_portals: @props.publicationDetails.latest_publication_portals
      polling: false

    componentDidMount: ->
      @poller = setInterval @pollForChanges, 5000

    componentWillUnmount: ->
      clearInterval @poller

    pollForChanges: ->
      $.ajax
        url: @props.publicationDetails.poll_url
        type: 'GET',
        success: (data) =>
          if data
            @setState
              last_publication_hash: data.last_publication_hash
              latest_publication_portals: data.latest_publication_portals

    render: ->
      numPortals = @state.latest_publication_portals.length
      plural = if numPortals > 1 then 's' else ''

      (div {className: 'publication_details'},
        (div {className: 'summary'},
          if numPortals > 0
            "This item has been published to #{numPortals} portal#{plural}. Any changes will automatically be published to the portal#{plural} below."
          else
            "This item is not published to any of the portals. Click on the publish button to publish this item."
        )
        (ul {className: 'details', style: {marginTop: 10}},
          for portal in @state.latest_publication_portals
            debugTitle = "Activity: #{@state.last_publication_hash} => Portal: #{portal.publication_hash}"
            (li {className: 'detail', key: portal.url},
              (span {className: 'detail'}, portal.domain)
              (span {className: 'detail'}, " : (#{portal.count} time#{if portal.count is 1 then '' else 's'}) - ")
              (span {className: 'detail'}, portal.date)
              if portal.success
                (span {className: 'message success-message', title: debugTitle}, if @state.last_publication_hash is portal.publication_hash then 'published' else 'publishing')
              else
                (span {className: 'message error-message', title: debugTitle}, 'not published!')
            )
        )
        (a {href: @props.publicationDetails.publish_url, className: 'btn btn-primary', 'data-remote': true}, 'Manually Publish')
      )