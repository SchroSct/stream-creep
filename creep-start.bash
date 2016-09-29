#!/bin/bash
##Example start script
##user1 = series of users 1:1 per model. ModelName=name as on the website
sudo -u user1 screen -d -m -S ModelName bash mfc-creep.bash "ModelName"
