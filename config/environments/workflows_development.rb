# will spawn worker(s) for each of the given workflows (fully qualified as "repo:wf:robot")
WORKFLOW_STEPS = %w{
  dor:demoWf:a1-first
  dor:demoWF:b2-second
  dor:demoWF:c3-third
}

# number of workers for the given workflows
# by default, 1 is started per item in WORKFLOW_STEPS
WORKFLOW_N = Hash[*%w{
  dor:demoWF:c3-third     3
}]
