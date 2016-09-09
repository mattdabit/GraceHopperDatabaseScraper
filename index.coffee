Nightmare = require 'nightmare'
fs = require 'fs'
Path = require 'path'

auth = require './auth.json'

women = []

nightmare = new Nightmare(loadImages: false)
.goto "http://apps.anitaborg.org/~abi/prod/resumes/web/index.php/GHC/sponsors/default/login"
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
  nightmare
  .goto "http://apps.anitaborg.org/~abi/prod/resumes/web/index.php/GHC/sponsors/application/view?id=#{id}"
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
  "University Student": attrs[12].textContent
  "Contact By": attrs[13].textContent
  "Attending": attrs[14].textContent
  GPA: attrs[15].textContent
  Major: attrs[16].textContent
  Education: attrs[17].textContent
  "Years of Experience": attrs[18].textContent
  "Current Position Type": attrs[19].textContent
  "Industry Experience": attrs[20].textContent
  Skills: attrs[21].textContent
  "Interested Academic Programs": attrs[22].textContent
  "Interested Academic Positions": attrs[23].textContent
  "Interested Non-Academic Positions": attrs[24].textContent
  "Interested Employment Type": attrs[25].textContent
  "Interest Field": attrs[26].textContent
  Availability: attrs[27].textContent
  "Current Job Status": attrs[28].textContent
  Comments: attrs[29].textContent
  "Locations for Employment": attrs[30].textContent

for page in [1..175]
  nightmare
  .goto "http://apps.anitaborg.org/~abi/prod/resumes/web/index.php/GHC/sponsors/application?page=#{page}"
  .wait '.kv-grid-table'
  .evaluate getIds, logIds

nightmare.run (err, n) ->
  console.error err if err isnt undefined
