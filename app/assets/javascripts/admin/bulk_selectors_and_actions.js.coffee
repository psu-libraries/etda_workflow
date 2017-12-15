setup_bulk_selectors_and_actions = () ->

  bulk_actions = $('#bulk-actions')
  table = $('.bulk-actions')

  number_of_rows_selected = () ->
    count = 0
    data_table = new $.fn.dataTable.Api(table)
    data_table.rows().nodes().to$().each( ->
      if $(this).find('.row-checkbox').prop('checked')
        count++
    )
    count

  number_of_visible_rows_selected = () ->
    count = 0
    data_table = new $.fn.dataTable.Api(table)
    data_table.$('tr',
      order:  'current'
      search: 'applied'
      page:   'current'
    ).each( ->
      if $(this).find('.row-checkbox').prop('checked')
        count++
    )
    count

  selected_ids = () ->
    array = []
    data_table = new $.fn.dataTable.Api(table)
    data_table.rows().nodes().to$().each( ->
      id = $(this).attr('data-submission-id')
      if $(this).find('.row-checkbox').prop('checked')
        array.push(id)
    )
    array

  update_selected_submission_ids_field = () ->
    fields = bulk_actions.find('input[name="submission_ids"]')
    ids = selected_ids()
    fields.val(ids)

  update_selected_release_date = () ->
    parent_form = $(this).closest('form')
    date_field = parent_form.find('input[name="date_to_release"]')
    date_prefix = $(this).data('date-prefix')
    month_select = $('#' + date_prefix + '_month')
    day_select = $('#' + date_prefix + '_day')
    year_select = $('#' + date_prefix + '_year')
    return unless date_field.length
    mo_da_yr = month_select.val()+'/'+day_select.val()+'/'+year_select.val()
    date_field.val(mo_da_yr)

  update_confirm_delete_messages = () ->
    confirm_message = "Are you sure you want to permanently delete the " + number_of_rows_selected() + " selected submission(s)?"
    delete_submits = bulk_actions.find('input[type="submit"].btn-danger')
    delete_submits.attr('data-confirm', confirm_message)

  update_bulk_actions = () ->
    selected = number_of_rows_selected()
    bulk_actions.find('h5 .number-of-selected-rows').html(selected)
    visible = number_of_visible_rows_selected()
    bulk_actions.find('h5 .number-of-visible-selected-rows').html(visible)
    update_confirm_delete_messages()
    if selected > 0
      bulk_actions.slideDown()
    else
      bulk_actions.slideUp()

  table.on( 'page.dt length.dt search.dt', ->
    update_bulk_actions()
  )

  table.on('change', 'tr .row-checkbox', ->
    update_selected_submission_ids_field()
    update_bulk_actions()
  )

  selection_buttons = $('#row-selection-buttons')

  return unless selection_buttons.length

  select_visible_buttons = $('.select-visible-button')
  deselect_visible_buttons = $('.deselect-visible-button')
  select_releasable_buttons = $('.select-releasable-button')


  select_visible_buttons.on('click', ->
    $('.row-checkbox').prop('checked', true)
    update_selected_submission_ids_field()
    update_bulk_actions()
  )

  deselect_visible_buttons.on('click', ->
    $('.row-checkbox').prop('checked', false)
    update_selected_submission_ids_field()
    update_bulk_actions()
  )

  select_releasable_buttons.on('click', ->
    data_table = new $.fn.dataTable.Api(table)
    column_index = data_table.column('ok_to_release:name').index()
    data_table.rows( (i, data, node)->
      ok_to_release = data[column_index]
      $(node).find('.row-checkbox').prop('checked', ok_to_release)
    )
    update_selected_submission_ids_field()
    update_bulk_actions()
    $(this).blur()
  )
  $('.release-button').on('click', update_selected_release_date)
  $('.extend-button').on('click',  update_selected_release_date)
  $('.csv').on 'click',  ->
    fields = $('#row-selection-buttons').find('input[name="submission_ids"]')
    ids = selected_ids()
    fields.val(ids)

$(document).on('page:load ready', setup_bulk_selectors_and_actions)