class SubmitDirtyAnswersJob < Struct.new(:run_id, :start_time)
  def enqueue(job)
    job.run_at = 30.seconds.from_now
  end

  def perform
    run = Run.find(run_id)
    # Find array of dirty answers and send them to the portal
    da = run.dirty_answers
    return if da.empty?
    if run.send_to_portal(da, start_time)
      # if there is a report service configured send run data there too:
      if ReportService::configured?
        begin
          force = false
          sender = ReportService::RunSender.new(run, force)
          sender.send()
        rescue => e
          Rail.logger.error("Couldn't send run to report service:")
          Rail.logger.error(e)
        end
      end
      run.set_answers_clean(da) # We're only cleaning the same set we sent to the portal
      run.reload
      if run.dirty_answers.empty?
        run.mark_clean
      else
        # I'm not sure about using this method here, because it raises an error when the
        # "problem" may just be that (a) new dirty answer(s) were submitted between the
        # send_to_portal call and the check here.
        run.abort_job_and_requeue
      end
    else
      run.abort_job_and_requeue
    end
  end
end
