class BH.Views.SettingsView extends BH.Views.BaseView
  className: 'settings_view'

  template: BH.Templates['settings']

  events:
    'click .clear_history': 'clickedClearHistory'
    'change .time_grouping': 'changedTimeGrouping'
    'change .time_format': 'changedTimeFormat'
    'change .open_location': 'changedOpenLocation'
    'change .starting_week_day': 'changedStartingWeekDay'
    'click .domain_grouping': 'clickedDomainGrouping'
    'click .search_by_domain': 'clickedSearchByDomain'
    'click .search_by_selection': 'clickedSearchBySelection'
    'click .credits': 'clickedCredits'

  initialize: ->
    @model.off 'change'
    @model.on 'change', @model.save, @model
    @model.on 'change:openLocation', @options.state.updateRoute, @options.state
    @model.on 'change:startingWeekDay', @options.state.updateRoute, @options.state

  pageTitle: ->
    chrome.i18n.getMessage('settings_title')

  select: ->
    super()
    !((d,s,id) ->
      js
      fjs=d.getElementsByTagName(s)[0];
      if !d.getElementById(id)
        js=d.createElement(s);
        js.id=id;
        js.src="https://platform.twitter.com/widgets.js";
        fjs.parentNode.insertBefore(js,fjs);
    )(document,"script","twitter-wjs");
    window.___gcfg = {lang: chrome.i18n.getMessage('google_plus_language')}
    (->
      po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
      po.src = 'https://apis.google.com/js/plusone.js';
      s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
    )()

  render: ->
    properties = _.extend {},
      @getI18nValues(),
      @model.toTemplate(),
      @options.version.toTemplate()

    @$el.append(@renderTemplate properties)
    @

  changedTimeGrouping: (ev) ->
    @model.set timeGrouping: $(ev.currentTarget).val()

  changedTimeFormat: (ev) ->
    @model.set timeFormat: $(ev.currentTarget).val()

  changedOpenLocation: (ev) ->
    @model.set openLocation: $(ev.currentTarget).val()

  changedStartingWeekDay: (ev) ->
    @model.set startingWeekDay: $(ev.currentTarget).val()

  clickedDomainGrouping: (ev) ->
    @model.set domainGrouping: $(ev.currentTarget).is(':checked')

  clickedSearchByDomain: (ev) ->
    @model.set searchByDomain: $(ev.currentTarget).is(':checked')

    backgroundPage = chrome.extension.getBackgroundPage()
    method = if @model.get('searchByDomain') then 'create' else 'remove'

    backgroundPage.pageContextMenu[method]()

  clickedSearchBySelection: (ev) ->
    @model.set searchBySelection: $(ev.currentTarget).is(':checked')

    backgroundPage = chrome.extension.getBackgroundPage()
    method = if @model.get('searchBySelection') then 'create' else 'remove'

    backgroundPage.selectionContextMenu[method]()

  clickedClearHistory: (ev) ->
    ev.preventDefault()
    chrome.tabs.create url:'chrome://settings/clearBrowserData'

  clickedCredits: (ev) ->
    ev.preventDefault()
    creditsView = new BH.Views.CreditsView()
    $('body').append(creditsView.render().el)
    creditsView.open()

  getI18nValues: ->
    properties = @i18nFetcher.get([
      'settings_title',
      'clearing_history_section_title',
      'clear_history_button',
      'visit_grouping_section_title',
      'group_visits_by_label',
      'time_format_label',
      'group_visits_by_domain_label',
      'right_click_options_section_title',
      'search_by_text_selection_label',
      'search_by_domain_label',
      'whats_new_section_title',
      'current_version_label',
      'feedback_section_title',
      'spread_the_word_section_title',
      'leave_a_review',
      'twitter_template',
      'twitter_language',
      'open_location',
      'starting_week_day',
      'general_section_title'
    ])
    properties[@i18nFetcher.scopeKey('credits_link')] = chrome.i18n.getMessage('credits_link', [
      '<strong>',
      '</strong>'
    ])
    properties[@i18nFetcher.scopeKey('suggestions_bugs_comments')] = chrome.i18n.getMessage('suggestions_bugs_comments', [
      '<a href="http://twitter.com/Better_History">',
      '</a>'
    ])
    properties
