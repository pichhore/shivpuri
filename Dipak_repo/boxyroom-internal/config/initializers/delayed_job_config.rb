Delayed::Job.destroy_failed_jobs = false

silence_warnings do
  Delayed::Job.const_set("MAX_ATTEMPTS", 20)
  Delayed::Job.const_set("MAX_RUN_TIME", 1.hour)
end