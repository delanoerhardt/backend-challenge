
wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"

array = {}
array_size = 10

init = function()
  math.randomseed(os.time())

  local base = [[
    {"name":"breada%d","equipments":[{"tool":"equipd%d","quantity":8}],"ingredients":[{"quantity_unit":"ml","quantity":"%d","food":"ingrea%d"},{"quantity_unit":"kg","quantity":"%d","food":"waterb%d"}],"description":"Yep, it's bread"}
  ]]
  for i = 1, array_size do
    array[i] = string.format(base, math.random(1000000), math.random(1000000), math.random(1000000), math.random(1000000), math.random(1000000), math.random(1000000))
    print(array[i])
  end
end

request = function()
  wrk.body = array[math.random(array_size)]
  return wrk.format("POST")
end