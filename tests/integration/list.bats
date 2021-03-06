#!/usr/bin/env bats

load helpers

function setup() {
  teardown_running_container_inroot test_box1 $HELLO_BUNDLE
  teardown_running_container_inroot test_box2 $HELLO_BUNDLE
  teardown_running_container_inroot test_box3 $HELLO_BUNDLE
  teardown_busybox
  setup_busybox
}

function teardown() {
  teardown_running_container_inroot test_box1 $HELLO_BUNDLE
  teardown_running_container_inroot test_box2 $HELLO_BUNDLE
  teardown_running_container_inroot test_box3 $HELLO_BUNDLE
  teardown_busybox
}

@test "list" {
  # start a few busyboxes detached
  run "$RUNC" --root $HELLO_BUNDLE start -d --console /dev/pts/ptmx test_box1
  [ "$status" -eq 0 ]
  wait_for_container_inroot 15 1 test_box1 $HELLO_BUNDLE
  
  run "$RUNC" --root $HELLO_BUNDLE start -d --console /dev/pts/ptmx test_box2
  [ "$status" -eq 0 ]
  wait_for_container_inroot 15 1 test_box2 $HELLO_BUNDLE
  
  run "$RUNC" --root $HELLO_BUNDLE start -d --console /dev/pts/ptmx test_box3
  [ "$status" -eq 0 ]
  wait_for_container_inroot 15 1 test_box3 $HELLO_BUNDLE
  
  run "$RUNC" --root $HELLO_BUNDLE list 
  [ "$status" -eq 0 ]
  [[ ${lines[0]} =~ ID\ +PID\ +STATUS\ +BUNDLE\ +CREATED+ ]]
  [[ "${lines[1]}" == *"test_box1"*[0-9]*"running"*$BUSYBOX_BUNDLE*[0-9]* ]]
  [[ "${lines[2]}" == *"test_box2"*[0-9]*"running"*$BUSYBOX_BUNDLE*[0-9]* ]]
  [[ "${lines[3]}" == *"test_box3"*[0-9]*"running"*$BUSYBOX_BUNDLE*[0-9]* ]]
  
  run "$RUNC" --root $HELLO_BUNDLE list --format table 
  [ "$status" -eq 0 ]
  [[ ${lines[0]} =~ ID\ +PID\ +STATUS\ +BUNDLE\ +CREATED+ ]]
  [[ "${lines[1]}" == *"test_box1"*[0-9]*"running"*$BUSYBOX_BUNDLE*[0-9]* ]]
  [[ "${lines[2]}" == *"test_box2"*[0-9]*"running"*$BUSYBOX_BUNDLE*[0-9]* ]]
  [[ "${lines[3]}" == *"test_box3"*[0-9]*"running"*$BUSYBOX_BUNDLE*[0-9]* ]]
  
  run "$RUNC" --root $HELLO_BUNDLE list --format json
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == [\[][\{]"\"id\""[:]"\"test_box1\""[,]"\"pid\""[:]*[0-9][,]"\"status\""[:]*"\"running\""[,]"\"bundle\""[:]*$BUSYBOX_BUNDLE*[,]"\"created\""[:]*[0-9]*[\}]* ]]
  [[ "${lines[0]}" == *[,][\{]"\"id\""[:]"\"test_box2\""[,]"\"pid\""[:]*[0-9][,]"\"status\""[:]*"\"running\""[,]"\"bundle\""[:]*$BUSYBOX_BUNDLE*[,]"\"created\""[:]*[0-9]*[\}]* ]]
  [[ "${lines[0]}" == *[,][\{]"\"id\""[:]"\"test_box3\""[,]"\"pid\""[:]*[0-9][,]"\"status\""[:]*"\"running\""[,]"\"bundle\""[:]*$BUSYBOX_BUNDLE*[,]"\"created\""[:]*[0-9]*[\}][\]] ]]
}
