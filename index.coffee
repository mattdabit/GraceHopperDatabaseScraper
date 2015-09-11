Nightmare = require 'nightmare'
fs = require 'fs'
Path = require 'path'

auth = require './auth.json'

women = []

n = new Nightmare(loadImages: false)
.goto "http://apps.gracehopper.org/~abi/prod/resumes/web/index.php/GHC-2015/sponsors/default/login"
.type '#loginform-username', auth.username
.type '#loginform-password', auth.password
.click '.btn-green'
.wait()

getIds = ->
  Array::slice.call(document.querySelectorAll('tbody tr')).map (tr) ->
    tr.getAttribute 'data-key'

logIds = (ids) ->
  ids.forEach (id) -> agentForId id

agentForId = (id) ->
  n
  .goto "http://apps.gracehopper.org/~abi/prod/resumes/web/index.php/GHC-2015/sponsors/application/view?id=#{id}"
  .evaluate getInfo, (woman) ->
    console.log "#{woman["First Name"]} #{woman["Last Name"]}\n#{woman.Phone}"
    women.push woman
    fs.writeFile Path.join(__dirname, 'attendees.json'), JSON.stringify(women, null, '\t')

getInfo = ->
  attrs = document.querySelectorAll('.form-group .view-lable span') #.view-lable is a typo in their HTML
  "First Name": attrs[0].textContent
  "Last Name": attrs[1].textContent
  Organization: attrs[2].textContent
  Phone: attrs[3].textContent
  Email: attrs[4].textContent
  Address: attrs[5].textContent
  City: attrs[6].textContent
  States: attrs[7].textContent
  "Zip Code": attrs[8].textContent
  Country: attrs[9].textContent
  "U.S. Citizen": attrs[10].textContent
  "Can Work in U.S.": attrs[11].textContent
  "Contact By": attrs[12].textContent
  "Attending": attrs[13].textContent
  GPA: attrs[14].textContent
  Major: attrs[15].textContent
  Education: attrs[16].textContent
  "Years of Experience": attrs[17].textContent
  "Current Position Type": attrs[18].textContent
  "Industry Experience": attrs[19].textContent
  Skills: attrs[20].textContent
  "Interested Academic Programs": attrs[21].textContent
  "Interested Academic Positions": attrs[22].textContent
  "Interested Non-Academic Positions": attrs[23].textContent
  "Interested Employment Type": attrs[24].textContent
  "Interest Field": attrs[25].textContent
  Availability: attrs[26].textContent
  "Current Job Status": attrs[27].textContent
  Comments: attrs[28].textContent
  "Locations for Employment": attrs[29].textContent

for page in [1..112]
  n
  .goto "http://apps.gracehopper.org/~abi/prod/resumes/web/index.php/GHC-2015/sponsors/application?page=#{page}"
  .wait '.kv-grid-table'
  .evaluate getIds, logIds

n.run (err, nightmare) ->
  console.error err if err isnt undefined
