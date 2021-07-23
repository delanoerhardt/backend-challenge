
wrk.path = "/get-recipes/"

path = "/get-recipes/"
last_seen_id = ""

response = function(status, headers, body)
  if status == 200 then
    body_size = string.len(body)
    
    for i = body_size, 1, -1 do
      if(body:sub(i, i) == ':') then
        last_seen_id = string.sub(body, i + 2, body_size - 2)

        break
      end
    end
  end
end


request = function()
  return wrk.format("GET", path .. last_seen_id)
end