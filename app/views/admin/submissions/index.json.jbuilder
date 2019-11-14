json.data @view.submission_views(params[:semester]),
          partial: @view.table_body_partial_path,
          as: :submission_view
