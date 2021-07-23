
wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"

math.randomseed(os.time())

base_ingredient = [[{"food":"%s","quantity":"9","quantity_unit":"ml"}]]
base_equipment = [[{"tool":"%s","quantity":9}]]
base_recipe = [[
  {"name":"%sbread","description":"Lorem ipsum","ingredients":[%s],"equipments":[%s]}
]]

food_examples = {"flour", "water", "yeast", "salt", "oil"}
food_examples_amount = #food_examples

tool_examples = {"bowl", "cup", "spoon", "spatula ", "oven"}
tool_examples_amount = #tool_examples

name_sufixes = {"Italian ", "Crumbs of ", "Banana ", "Flat", "Buckwheat "}
name_sufixes_amount = #name_sufixes

max_ingredients = 20
max_equipments = 10

arbitrary_value = 10000000

request = function()
  ingredients = {}
  ingredient_amount = math.random(max_ingredients)

  for i = 1, ingredient_amount do
    ingredients[i] =
      string.format(base_ingredient,
          food_examples[math.random(food_examples_amount)]
          .. math.random(arbitrary_value))
  end

  equipments = {}
  equipments_amount = math.random(max_equipments)

  for i = 1, equipments_amount do
    equipments[i] =
        string.format(base_equipment,
          tool_examples[math.random(tool_examples_amount)]
          .. math.random(arbitrary_value))
  end

  wrk.body =
      string.format(base_recipe,
        name_sufixes[math.random(name_sufixes_amount)],
        table.concat(ingredients, ","),
        table.concat(equipments, ",")
      )
  return wrk.format("POST")
end