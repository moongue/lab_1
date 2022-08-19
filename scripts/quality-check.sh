#!/usr/bin/env bash

APP_ROOT=*/

cd $APP_ROOT

npm audit
npm run lint
npm run test
npm run e2e

echo 'Quality check finished'
