-- ky_food/init.lua
-- KY Food Mod for Minetest/Luanti
-- Code License: MIT (ronrob-lu 2026)
-- Assets License: CC0 1.0 Universal (Kenney.nl)

local modname = minetest.get_current_modname() or "ky_food"

-- Game environment detection
local is_mcl = minetest.get_modpath("mcl_core") ~= nil
local is_default = minetest.get_modpath("default") ~= nil

-- Common item / group resolvers for cross-game support
local WHEAT = is_mcl and "mcl_farming:wheat" or (is_default and "default:wheat" or "group:food_wheat")
local BREAD = is_mcl and "mcl_farming:bread" or (is_default and "default:bread" or "group:food_bread")
local APPLE = is_mcl and "mcl_core:apple" or (is_default and "default:apple" or "group:food_apple")
local SUGAR = is_mcl and "mcl_core:sugar" or (is_default and "farming:sugar" or "group:food_sugar")
local PAPER = is_mcl and "mcl_core:paper" or (is_default and "default:paper" or "group:paper")
local WATER = is_mcl and "mcl_buckets:bucket_water" or (is_default and "default:water_bucket" or "group:water_bucket")
local MILK  = is_mcl and "mcl_mobs:bucket_milk" or (is_default and "mobs:bucket_milk" or "group:food_milk")
local EGG   = is_mcl and "mcl_mobitems:egg" or "group:food_egg"
local MEAT  = is_mcl and "mcl_flesh:raw_beef" or (is_default and "mobs:meat_raw" or "group:food_meat_raw")
local COOKED_MEAT = is_mcl and "mcl_flesh:cooked_beef" or (is_default and "mobs:meat" or "group:food_meat")
local WOOD  = "group:wood"
local STEEL = is_mcl and "mcl_core:iron_ingot" or (is_default and "default:steel_ingot" or "group:food_steel")
local GLASS = is_mcl and "mcl_core:glass" or (is_default and "default:glass" or "group:glass")

-- Generic eating/drinking callback that supports both MTG (minetest.item_eat) and MCL (mcl_hungerv2 / mcl_farming)
local function eat_item(hp_change, replace_with_item)
	return function(itemstack, user, pointed_thing)
		if not user or not user:is_player() then
			return itemstack
		end

		-- MCL Hunger system integration if available
		if is_mcl and minetest.get_modpath("mcl_hungerv2") and mcl_hungerv2.eat then
			return mcl_hungerv2.eat(hp_change, replace_with_item)(itemstack, user, pointed_thing)
		end

		-- Default Minetest / Luanti eat behavior
		return minetest.item_eat(hp_change, replace_with_item)(itemstack, user, pointed_thing)
	end
end

-- Item definitions helper
local function register_ky_item(id, title, nutrition, is_drink)
	local clean_id = id:lower():gsub("-", "_")
	local item_name = modname .. ":" .. clean_id
	local desc = title

	local groups = {food = 1, oddly_breakable_by_hand = 3}
	if nutrition > 0 then
		if is_drink then
			groups.food_drink = 1
		else
			groups.food_edible = 1
		end
	else
		groups.kitchen_tool = 1
	end

	minetest.register_node(item_name, {
		description = desc,
		drawtype = "mesh",
		mesh = id .. ".obj",
		tiles = {"food_colormap.png"},
		inventory_image = id .. ".png",
		wield_image = id .. ".png",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-0.25, -0.5, -0.25, 0.25, 0.0, 0.25}
		},
		groups = groups,
		on_use = (nutrition > 0) and eat_item(nutrition) or nil,
	})
end

-- Registry Table: id, title, nutrition, is_drink
local item_catalog = {
	{"advocado-half", "Advocado Half", 2, false},
	{"apple", "Apple", 2, false},
	{"apple-half", "Apple Half", 2, false},
	{"avocado", "Avocado", 2, false},
	{"bacon", "Bacon", 5, false},
	{"bacon-raw", "Bacon Raw", 2, false},
	{"bag", "Bag", 0, false},
	{"bag-flat", "Bag Flat", 0, false},
	{"banana", "Banana", 2, false},
	{"barrel", "Barrel", 0, false},
	{"beet", "Beet", 2, false},
	{"bottle-ketchup", "Bottle Ketchup", 0, false},
	{"bottle-musterd", "Bottle Musterd", 0, false},
	{"bottle-oil", "Bottle Oil", 0, false},
	{"bowl", "Bowl", 0, false},
	{"bowl-broth", "Bowl Broth", 5, false},
	{"bowl-cereal", "Bowl Cereal", 5, false},
	{"bowl-soup", "Bowl Soup", 5, false},
	{"bread", "Bread", 5, false},
	{"broccoli", "Broccoli", 2, false},
	{"burger", "Burger", 8, false},
	{"burger-cheese", "Burger Cheese", 8, false},
	{"burger-cheese-double", "Burger Cheese Double", 8, false},
	{"burger-double", "Burger Double", 8, false},
	{"cabbage", "Cabbage", 2, false},
	{"cake", "Cake", 8, false},
	{"cake-birthday", "Cake Birthday", 8, false},
	{"cake-slicer", "Cake Slicer", 0, false},
	{"can", "Can", 0, false},
	{"can-open", "Can Open", 0, false},
	{"can-small", "Can Small", 0, false},
	{"candy-bar", "Candy Bar", 2, false},
	{"candy-bar-wrapper", "Candy Bar Wrapper", 0, false},
	{"carrot", "Carrot", 2, false},
	{"carton", "Carton", 0, false},
	{"carton-small", "Carton Small", 0, false},
	{"cauliflower", "Cauliflower", 2, false},
	{"celery-stick", "Celery Stick", 2, false},
	{"cheese", "Cheese", 5, false},
	{"cheese-cut", "Cheese Cut", 2, false},
	{"cheese-slicer", "Cheese Slicer", 0, false},
	{"cherries", "Cherries", 2, false},
	{"chinese", "Chinese", 5, false},
	{"chocolate", "Chocolate", 2, false},
	{"chocolate-wrapper", "Chocolate Wrapper", 0, false},
	{"chopstic-decorative", "Chopstic Decorative", 0, false},
	{"chopstick", "Chopstick", 0, false},
	{"cocktail", "Cocktail", 3, true},
	{"coconut", "Coconut", 2, false},
	{"coconut-half", "Coconut Half", 2, false},
	{"cookie", "Cookie", 2, false},
	{"cookie-chocolate", "Cookie Chocolate", 2, false},
	{"cooking-fork", "Cooking Fork", 0, false},
	{"cooking-knife", "Cooking Knife", 0, false},
	{"cooking-knife-chopping", "Cooking Knife Chopping", 0, false},
	{"cooking-spatula", "Cooking Spatula", 0, false},
	{"cooking-spoon", "Cooking Spoon", 0, false},
	{"corn", "Corn", 2, false},
	{"corn-dog", "Corn Dog", 2, false},
	{"croissant", "Croissant", 5, false},
	{"cup", "Cup", 3, true},
	{"cup-coffee", "Cup Coffee", 3, true},
	{"cup-saucer", "Cup Saucer", 3, true},
	{"cup-tea", "Cup Tea", 3, true},
	{"cupcake", "Cupcake", 2, false},
	{"cutting-board", "Cutting Board", 0, false},
	{"cutting-board-japanese", "Cutting Board Japanese", 0, false},
	{"cutting-board-round", "Cutting Board Round", 0, false},
	{"dim-sum", "Dim Sum", 5, false},
	{"donut", "Donut", 2, false},
	{"donut-chocolate", "Donut Chocolate", 2, false},
	{"donut-sprinkles", "Donut Sprinkles", 2, false},
	{"egg", "Egg", 2, false},
	{"egg-cooked", "Egg Cooked", 5, false},
	{"egg-cup", "Egg Cup", 0, false},
	{"egg-half", "Egg Half", 2, false},
	{"eggplant", "Eggplant", 2, false},
	{"fish", "Fish", 2, false},
	{"fish-bones", "Fish Bones", 0, false},
	{"frappe", "Frappe", 3, true},
	{"fries", "Fries", 5, false},
	{"fries-empty", "Fries Empty", 0, false},
	{"frikandel-speciaal", "Frikandel Speciaal", 8, false},
	{"frying-pan", "Frying Pan", 0, false},
	{"frying-pan-lid", "Frying Pan Lid", 0, false},
	{"ginger-bread", "Ginger Bread", 2, false},
	{"ginger-bread-cutter", "Ginger Bread Cutter", 0, false},
	{"glass", "Glass", 0, false},
	{"glass-wine", "Glass Wine", 3, true},
	{"grapes", "Grapes", 2, false},
	{"honey", "Honey", 2, false},
	{"hot-dog", "Hot Dog", 5, false},
	{"hot-dog-raw", "Hot Dog Raw", 2, false},
	{"ice-cream", "Ice Cream", 2, false},
	{"ice-cream-cne", "Ice Cream Cne", 0, false},
	{"ice-cream-cup", "Ice Cream Cup", 0, false},
	{"ice-cream-scoop-chocolate", "Ice Cream Scoop Chocolate", 2, false},
	{"ice-cream-scoop-mint", "Ice Cream Scoop Mint", 2, false},
	{"knife-block", "Knife Block", 0, false},
	{"leek", "Leek", 2, false},
	{"lemon", "Lemon", 2, false},
	{"lemon-half", "Lemon Half", 2, false},
	{"loaf", "Loaf", 5, false},
	{"loaf-baguette", "Loaf Baguette", 5, false},
	{"loaf-round", "Loaf Round", 5, false},
	{"lollypop", "Lollypop", 2, false},
	{"maki-roe", "Maki Roe", 5, false},
	{"maki-salmon", "Maki Salmon", 5, false},
	{"maki-vegetable", "Maki Vegetable", 5, false},
	{"meat-cooked", "Meat Cooked", 5, false},
	{"meat-patty", "Meat Patty", 5, false},
	{"meat-raw", "Meat Raw", 2, false},
	{"meat-ribs", "Meat Ribs", 5, false},
	{"meat-sausage", "Meat Sausage", 5, false},
	{"meat-tenderizer", "Meat Tenderizer", 0, false},
	{"mincemeat-pie", "Mincemeat Pie", 8, false},
	{"mortar", "Mortar", 0, false},
	{"mortar-pestle", "Mortar Pestle", 0, false},
	{"muffin", "Muffin", 2, false},
	{"mug", "Mug", 0, false},
	{"mushroom", "Mushroom", 2, false},
	{"mushroom-half", "Mushroom Half", 2, false},
	{"mussel", "Mussel", 2, false},
	{"mussel-open", "Mussel Open", 2, false},
	{"onion", "Onion", 2, false},
	{"onion-half", "Onion Half", 2, false},
	{"orange", "Orange", 2, false},
	{"pan", "Pan", 0, false},
	{"pan-stew", "Pan Stew", 0, false},
	{"pancakes", "Pancakes", 8, false},
	{"paprika", "Paprika", 2, false},
	{"paprika-slice", "Paprika Slice", 2, false},
	{"peanut-butter", "Peanut Butter", 2, false},
	{"pear", "Pear", 2, false},
	{"pear-half", "Pear Half", 2, false},
	{"pepper", "Pepper", 2, false},
	{"pepper-mill", "Pepper Mill", 0, false},
	{"pie", "Pie", 8, false},
	{"pineapple", "Pineapple", 2, false},
	{"pizza", "Pizza", 8, false},
	{"pizza-box", "Pizza Box", 0, false},
	{"pizza-cutter", "Pizza Cutter", 0, false},
	{"plate", "Plate", 0, false},
	{"plate-broken", "Plate Broken", 0, false},
	{"plate-deep", "Plate Deep", 0, false},
	{"plate-dinner", "Plate Dinner", 0, false},
	{"plate-rectangle", "Plate Rectangle", 0, false},
	{"plate-sauerkraut", "Plate Sauerkraut", 8, false},
	{"popsicle", "Popsicle", 2, false},
	{"popsicle-chocolate", "Popsicle Chocolate", 2, false},
	{"popsicle-stick", "Popsicle Stick", 0, false},
	{"pot", "Pot", 0, false},
	{"pot-lid", "Pot Lid", 0, false},
	{"pot-stew", "Pot Stew", 0, false},
	{"pot-stew-lid", "Pot Stew Lid", 0, false},
	{"pudding", "Pudding", 2, false},
	{"pumpkin", "Pumpkin", 2, false},
	{"pumpkin-basic", "Pumpkin Basic", 2, false},
	{"radish", "Radish", 2, false},
	{"rice-ball", "Rice Ball", 5, false},
	{"rollingPin", "Rollingpin", 0, false},
	{"salad", "Salad", 5, false},
	{"sandwich", "Sandwich", 8, false},
	{"sausage", "Sausage", 5, false},
	{"sausage-half", "Sausage Half", 2, false},
	{"shaker-pepper", "Shaker Pepper", 0, false},
	{"shaker-salt", "Shaker Salt", 0, false},
	{"skewer", "Skewer", 5, false},
	{"skewer-vegetables", "Skewer Vegetables", 5, false},
	{"soda", "Soda", 3, true},
	{"soda-bottle", "Soda Bottle", 3, true},
	{"soda-can", "Soda Can", 3, true},
	{"soda-can-crushed", "Soda Can Crushed", 0, false},
	{"soda-glass", "Soda Glass", 3, true},
	{"soy", "Soy", 2, false},
	{"steamer", "Steamer", 0, false},
	{"strawberry", "Strawberry", 2, false},
	{"styrofoam", "Styrofoam", 0, false},
	{"styrofoam-dinner", "Styrofoam Dinner", 0, false},
	{"sub", "Sub", 8, false},
	{"sundae", "Sundae", 2, false},
	{"sushi-egg", "Sushi Egg", 5, false},
	{"sushi-salmon", "Sushi Salmon", 5, false},
	{"taco", "Taco", 5, false},
	{"tajine", "Tajine", 0, false},
	{"tajine-lid", "Tajine Lid", 0, false},
	{"tomato", "Tomato", 2, false},
	{"tomato-slice", "Tomato Slice", 2, false},
	{"turkey", "Turkey", 8, false},
	{"utensil-fork", "Utensil Fork", 0, false},
	{"utensil-knife", "Utensil Knife", 0, false},
	{"utensil-spoon", "Utensil Spoon", 0, false},
	{"waffle", "Waffle", 8, false},
	{"watermelon", "Watermelon", 2, false},
	{"whipped-cream", "Whipped Cream", 2, false},
	{"whisk", "Whisk", 0, false},
	{"whole-ham", "Whole Ham", 8, false},
	{"wholer-ham", "Wholer Ham", 8, false},
	{"wine-red", "Wine Red", 3, true},
	{"wine-white", "Wine White", 3, true},
}

for _, item in ipairs(item_catalog) do
	register_ky_item(item[1], item[2], item[3], item[4])
end

--------------------------------------------------------------------------------
-- Crafting Recipes
--------------------------------------------------------------------------------

local function register_recipes()
	-- Beverages & Drinks (All craftable with water or milk)
	minetest.register_craft({
		output = modname .. ":cup_coffee",
		recipe = {
			{SUGAR, MILK, ""},
			{"", modname .. ":cup", ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":cup_tea",
		recipe = {
			{WATER, SUGAR, ""},
			{"", modname .. ":cup", ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":cup_saucer",
		recipe = {
			{WATER, SUGAR, ""},
			{"", modname .. ":cup", ""},
			{"", modname .. ":plate", ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":cup",
		recipe = {
			{"", "", ""},
			{GLASS, "", GLASS},
			{"", GLASS, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":mug",
		recipe = {
			{WOOD, "", WOOD},
			{"", WOOD, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":glass",
		recipe = {
			{GLASS, "", GLASS},
			{"", GLASS, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":soda 2",
		recipe = {
			{SUGAR, WATER, SUGAR}
		}
	})

	minetest.register_craft({
		output = modname .. ":soda_can 2",
		recipe = {
			{SUGAR, WATER, ""},
			{"", PAPER, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":soda_bottle 2",
		recipe = {
			{WATER, SUGAR, WATER}
		}
	})

	minetest.register_craft({
		output = modname .. ":soda_glass",
		recipe = {
			{WATER, SUGAR, ""},
			{"", modname .. ":glass", ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":cocktail",
		recipe = {
			{APPLE, WATER, SUGAR},
			{"", modname .. ":glass", ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":frappe",
		recipe = {
			{MILK, SUGAR, MILK},
			{"", modname .. ":cup", ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":wine_red",
		recipe = {
			{APPLE, APPLE, WATER}
		}
	})

	minetest.register_craft({
		output = modname .. ":wine_white",
		recipe = {
			{APPLE, SUGAR, WATER}
		}
	})

	minetest.register_craft({
		output = modname .. ":glass_wine",
		recipe = {
			{modname .. ":wine_red", ""},
			{"", modname .. ":glass", ""}
		}
	})

	-- Food & Bakery Recipes
	minetest.register_craft({
		output = modname .. ":bread 2",
		recipe = {
			{WHEAT, WHEAT, WHEAT}
		}
	})

	minetest.register_craft({
		output = modname .. ":sandwich",
		recipe = {
			{BREAD},
			{COOKED_MEAT},
			{BREAD}
		}
	})

	minetest.register_craft({
		output = modname .. ":sub",
		recipe = {
			{BREAD, COOKED_MEAT, BREAD}
		}
	})

	minetest.register_craft({
		output = modname .. ":burger",
		recipe = {
			{BREAD},
			{modname .. ":meat_patty"},
			{BREAD}
		}
	})

	minetest.register_craft({
		output = modname .. ":burger_cheese",
		recipe = {
			{BREAD},
			{modname .. ":cheese"},
			{modname .. ":meat_patty"}
		}
	})

	minetest.register_craft({
		output = modname .. ":burger_double",
		recipe = {
			{BREAD},
			{modname .. ":meat_patty"},
			{modname .. ":meat_patty"}
		}
	})

	minetest.register_craft({
		output = modname .. ":burger_cheese_double",
		recipe = {
			{BREAD},
			{modname .. ":cheese"},
			{modname .. ":burger_double"}
		}
	})

	minetest.register_craft({
		output = modname .. ":pizza",
		recipe = {
			{WHEAT, modname .. ":cheese", WHEAT},
			{WHEAT, COOKED_MEAT, WHEAT}
		}
	})

	minetest.register_craft({
		output = modname .. ":meat_patty 2",
		recipe = {
			{MEAT}
		}
	})

	minetest.register_craft({
		output = modname .. ":meat_cooked",
		recipe = {
			{COOKED_MEAT}
		}
	})

	minetest.register_craft({
		output = modname .. ":bacon",
		recipe = {
			{modname .. ":bacon_raw"}
		}
	})

	minetest.register_craft({
		output = modname .. ":hot_dog",
		recipe = {
			{BREAD, modname .. ":sausage", ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":fries",
		recipe = {
			{PAPER, WHEAT, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":cheese",
		recipe = {
			{MILK, MILK, MILK}
		}
	})

	minetest.register_craft({
		output = modname .. ":cheese_cut 4",
		recipe = {
			{modname .. ":cheese"}
		}
	})

	minetest.register_craft({
		output = modname .. ":cookie 4",
		recipe = {
			{WHEAT, SUGAR, WHEAT}
		}
	})

	minetest.register_craft({
		output = modname .. ":cookie_chocolate 4",
		recipe = {
			{WHEAT, SUGAR, SUGAR}
		}
	})

	minetest.register_craft({
		output = modname .. ":donut 2",
		recipe = {
			{WHEAT, SUGAR, WHEAT}
		}
	})

	minetest.register_craft({
		output = modname .. ":donut_chocolate 2",
		recipe = {
			{modname .. ":donut", SUGAR, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":donut_sprinkles 2",
		recipe = {
			{modname .. ":donut", SUGAR, SUGAR}
		}
	})

	minetest.register_craft({
		output = modname .. ":cake",
		recipe = {
			{MILK, SUGAR, MILK},
			{EGG, WHEAT, EGG}
		}
	})

	minetest.register_craft({
		output = modname .. ":cake_birthday",
		recipe = {
			{modname .. ":cake", SUGAR, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":cupcake 2",
		recipe = {
			{WHEAT, SUGAR, EGG}
		}
	})

	minetest.register_craft({
		output = modname .. ":muffin 2",
		recipe = {
			{WHEAT, SUGAR, MILK}
		}
	})

	minetest.register_craft({
		output = modname .. ":pancakes",
		recipe = {
			{WHEAT, MILK, EGG}
		}
	})

	minetest.register_craft({
		output = modname .. ":waffle",
		recipe = {
			{WHEAT, SUGAR, EGG}
		}
	})

	minetest.register_craft({
		output = modname .. ":pie",
		recipe = {
			{WHEAT, APPLE, SUGAR}
		}
	})

	minetest.register_craft({
		output = modname .. ":mincemeat_pie",
		recipe = {
			{WHEAT, COOKED_MEAT, WHEAT}
		}
	})

	minetest.register_craft({
		output = modname .. ":ice_cream",
		recipe = {
			{MILK, SUGAR, APPLE}
		}
	})

	minetest.register_craft({
		output = modname .. ":sundae",
		recipe = {
			{modname .. ":ice_cream", SUGAR, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":chocolate 2",
		recipe = {
			{SUGAR, MILK, SUGAR}
		}
	})

	minetest.register_craft({
		output = modname .. ":candy_bar 2",
		recipe = {
			{modname .. ":chocolate", SUGAR, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":lollypop 4",
		recipe = {
			{SUGAR, PAPER, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":popsicle",
		recipe = {
			{APPLE, SUGAR, PAPER}
		}
	})

	minetest.register_craft({
		output = modname .. ":popsicle_chocolate",
		recipe = {
			{modname .. ":chocolate", SUGAR, PAPER}
		}
	})

	-- Kitchenware / Tools Recipes
	minetest.register_craft({
		output = modname .. ":cutting_board",
		recipe = {
			{WOOD, WOOD, WOOD}
		}
	})

	minetest.register_craft({
		output = modname .. ":frying_pan",
		recipe = {
			{STEEL, STEEL, ""},
			{"", STEEL, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":pot",
		recipe = {
			{STEEL, "", STEEL},
			{STEEL, STEEL, STEEL}
		}
	})

	minetest.register_craft({
		output = modname .. ":bowl 2",
		recipe = {
			{WOOD, "", WOOD},
			{"", WOOD, ""}
		}
	})

	minetest.register_craft({
		output = modname .. ":plate 2",
		recipe = {
			{WOOD, WOOD, WOOD}
		}
	})

	-- Cooking / Smelting recipes
	minetest.register_craft({
		type = "cooking",
		output = modname .. ":egg_cooked",
		recipe = modname .. ":egg",
		cooktime = 5,
	})

	minetest.register_craft({
		type = "cooking",
		output = modname .. ":bacon",
		recipe = modname .. ":bacon_raw",
		cooktime = 5,
	})

	minetest.register_craft({
		type = "cooking",
		output = modname .. ":hot_dog",
		recipe = modname .. ":hot_dog_raw",
		cooktime = 6,
	})
end

register_recipes()

minetest.log("action", "[ky_food] Loaded 200 items with MTG & MCL support!")
