_ = require("lodash")
api = require("./api")

events = [
  "start"
  "hook"
  "hook end"
  "suite"
  "suite end"
  "test"
  "test end"
  "pass"
  "fail"
  "pending"
  "waiting"
  "end"
]

batchLimit = 100
batch = []

testInfo = (test)->
  info = null
  if test?
    info = _.pick(test, "root", "title", "speed", "duration")
    info.parentTitle = test.parent?.fullTitle()
  info

handle = (data)->
  batch.push(data)
  if batch.length >= batchLimit or data.event is "end"
    api.send("batch-report", { tests: batch })
    batch = []

report = (event, test, err)->
  handle({
    event: event
    info: testInfo test
    err: err and _.pick(err, "message", "stack", "actual", "expected", "showDiff")
  })

module.exports = (runner)->
  for event in events
    runner.on(event, _.partial(report, event))
