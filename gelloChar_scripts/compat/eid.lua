if EID == nil then return end
local Mod = GelloCharMod

local icons = Sprite()
icons:Load("gfx/ui_gello/eid/EID.anm2", true)

EID:addIcon("Player"..Mod.Enum.Character.GELLO,          "Player",   0, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B1,       "Player",   1, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B2,       "Player",   2, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B3,       "Player",   3, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B4,       "Player",   4, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B5,       "Player",   5, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B6,       "Player",   6, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B7,       "Player",   7, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B8,       "Player",   8, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B9,       "Player",   9, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B10,      "Player",  10, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B11,      "Player",  11, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B12,      "Player",  12, 16, 16, -1, 0, icons)
EID:addIcon("Player"..Mod.Enum.Character.GELLO_B13,      "Player",  13, 16, 16, -1, 0, icons)
EID:addIcon("TaintedGello",                              "Player",  13, 16, 16, -1, 0, icons)

EID:addIcon("Card"..Mod.Enum.Card.SACRIFICIAL_DAGGER,    "Cards",    0, 16, 16, -1, 0, icons)
EID:addIcon("Card"..Mod.Enum.Card.SOUL_OF_GELLO,         "Cards",    1, 16, 16, -1, 0, icons)


local makeDesc = function(...) return Mod:MakeDescription(...) end

local hamsterDesc = {
	Desc = {
		en_us = makeDesc(
			"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER.."}} Does 30 points of damage to all enemies in the room",
			"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_2.."}} Slows all enemies in the room 5 seconds",
			"{{Blank}} On death they freeze",
			"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_3.."}} Sets all enemies in the room on fire for 5 seconds",
			"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_4.."}} Heals Isaac for 1 Heart",
			"{{Blank}} If Isaac doesn't have space for Hearts it gives 1 Soul Heart",
			"Swaps the item to one of these"),

		spa = makeDesc(
			"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER.."}} Hace 30 puntos de daño a todos los enemigos en el cuarto",
			"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_2.."}} Relentiza a todos los enemigos en el cuarto por 5 segundos",
			"{{Blank}} Cuando se mueren se congelan",
			"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_3.."}} Prende a todos los enemigos en fuego por 5 segundos",
			"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_4.."}} Cura un Corazón",
			"{{Blank}} Si Isaac no tiene espacio para corazones, le da un Corazón de Alma",
			"Cambia el objeto a uno de estos"),
	},
	Name = {
		en_us = "Lil Hamster",
		spa = "Pequeño Hamster",
	}
}


local itemsDesc = {
	{ID = Mod.Enum.Item.LIL_HAMSTER, Desc = hamsterDesc.Desc, Name = hamsterDesc.Name},
	{ID = Mod.Enum.Item.LIL_HAMSTER_2, Desc = hamsterDesc.Desc, Name = hamsterDesc.Name},
	{ID = Mod.Enum.Item.LIL_HAMSTER_3, Desc = hamsterDesc.Desc, Name = hamsterDesc.Name},
	{ID = Mod.Enum.Item.LIL_HAMSTER_4, Desc = hamsterDesc.Desc, Name = hamsterDesc.Name},

	{ID = Mod.Enum.Item.BEELZEBUB, Desc = {
		en_us = makeDesc(
			"Gives a familiar that follows Isaac",
			"The familiar will get tired after some time",
			"This will create a rock wave around them that can damage enemies",
			"After some time it will get up again and follow Isaac",
			"The familiar will get tire quicker if it is moving"),

		spa = makeDesc(
			"Da un familiar que sigue a Isaac",
			"El familiar se cansara despues de un tiempo",
			"Esto creara una onda alrededor de este que dañara a enemigos",
			"Despues de un tiempo se volvera a levantar y seguir a Isaac",
			"El familiar se cansara más rapido si se esta moviendo")
	}, Name = {
		en_us = "Beelzebub",
	}},

	{ID = Mod.Enum.Item.FETAL_JAR, Desc = {
		en_us = makeDesc(
			"On use",
			"{{ArrowUp}} +1 Life",
			"{{ArrowDown}} Removes an item from Isaac",
			"When respawning",
			"{{ArrowUp}} {{Damage}} + 0.5 Damage",
			"{{ArrowUp}} {{Tears}} + 0.24 Tears",
			"{{ArrowUp}} Size down"),

		spa = makeDesc(
			"Al usarlo",
			"{{ArrowUp}} +1 Vida extra",
			"{{ArrowDown}} Le remueve un objeto a Isaac",
			"Al revivir",
			"{{ArrowUp}} {{Damage}} + 0.5 Daño",
			"{{ArrowUp}} {{Tears}} + 0.24 Lágrimas",
			"{{ArrowUp}} Reduce tu tamaño"),
	}, Name = {
		en_us = "Fetal Jar",
		spa = "Jarra Fetal",
	}},

	{ID = Mod.Enum.Item.MOTHERLY_CHICKEN, Desc = {
		en_us = "Clearing a room or wave has a 25% to give a random familiar for the floor",
		spa = "Limpiar un cuarto u ola, tiene un 25% de dar un familiar por la duración del piso",
	}, Name = {
		en_us = "Motherly Chicken",
		spa = "Gallina Maternal",
	}},

	{ID = Mod.Enum.Item.USE_PLACENTA, Desc = {
		en_us = makeDesc(
			"{{SoulHeart}} + 2 Soul Hearts",
			"Killing an enemy has a 7.5% to drop Half a Soul Heart",
			"{{Blank}} Some times drops a Full Soul Heart",
			"{{Blank}} And Rarely drops a Black Heart"),

		spa = makeDesc(
			"{{SoulHeart}} + 2 Corazones de Alma",
			"Matar a un enemigo tiene un 7.5% de dejar Medio Corazón de Alma",
			"{{Blank}} Aveces sueltan un Corazón de Alma entero",
			"{{Blank}} Y muy raras veces sueltan un Corazón Negro"),
	}, Name = {
		en_us = "Use Placenta",
		spa = "Placenta Usada",
	}},

	{ID = Mod.Enum.Item.CURSED_PLUSHIE, Desc = {
		en_us = makeDesc(
			"{{BlackHeart}} + 1 Black Heart",
			"{{ArrowUp}} {{Damage}} + 1.5 Damage",
			"{{ArrowUp}} Per Half a Black Heart",
			"{{Blank}} + x0.025 Damage multiplier",
			"Black hearts are slightly more common"),

		spa = makeDesc(
			"{{BlackHeart}} + 1 Corazón Negro",
			"{{ArrowUp}} {{Damage}} + 1.5 Daño",
			"{{ArrowUp}} Por cada medio Corazón Negro",
			"{{Blank}} + x0.025 Multiplicador de Daño",
			"Corazónes Negros son ligeramente más comunes"),
	}, Name = {
		en_us = "Cursed Plushie",
		spa = "Muñeco Maldito",
	}},

	{ID = Mod.Enum.Item.GALLUS, Desc = {
		en_us = makeDesc(
			"Killing an enemy has a 10% to spawn a special mini isaac",
			"This mini isaac has more health and does more damage"),
		
		spa = makeDesc(
			"Matar a un enmigo tiene un 10% de generar un mini isaac especial",
			"Este mini isaac tiene más vida y hace mas daño"),
	}, Name = {
		en_us = "Gallus",
	}},

	{ID = Mod.Enum.Item.LARRY_JR_JR, Desc = {
		en_us = makeDesc(
			"Gives a familiar with many sections that moves around the room",
			"If the familiar kill an enemy may make one of its sections transforme and grant it an effect"
			--[["If the familiar kill an enemy may give one of these effects to one of its sections",
			"Skin : Does more contact damage",
			"Blue : From time to time spawns a creep that petrify and damage enemies",
			"{{Blank}} If the head kill an enemy spawns a bigger version of the creep",
			"Green : From time to time one of the sections will shoots 3 to 5 tears",
			"{{Blank}} If the head kill an enemy shoots 3 tears to the direction that its moving",
			"Rocky : From time to time one of the sections will spawn a blue fly",
			"{{Blank}} If the head kill an enemy it will create a rock wave around the head"]]),
		
		spa = makeDesc(
			"Da un familiar con varias secciones que se mueve por el cuarto",
			"Si mata a un enemigo puede que una de las secciones se transforme y obtenga un efecto"
			--[["Si mata a un enemigo puede que se convierta una de las secciones a uno de estos efectos",
			"Piel : Hace más daño por contacto",
			"Azul : Cada cierto tiempo genera un charco que petrifica y daña a enemigos",
			"{{Blank}} Si la cabeza mata a un enemigo genera un charco mas grande",
			"Verde : Cada cierto tiempo una de las secciones disparara 3 a 5 lágrimas",
			"{{Blank}} Si la cabeza mata a un enemigo, dispara 3 lágrimas a la dirección que se estaba moviendo",
			"Piedra : Cada cierto tiempo una de las secciones generara una mosca",
			"{{Blank}} Si la cabeza mata a un enemigo generara una onda alrededor de su cabeza"]]),
	}, Name = {
		en_us = "Larry Jr Jr",
	}},

	{ID = Mod.Enum.Item.CENTEPIED, Desc = {
		en_us = makeDesc(
			"Spawns a centepied around Isaac that shield them from enemies projectiles",
			"Each section of the centepied will be destroid after taking certain amount of hits",
			"The centepied will disappear if it has 4 or less sections",
			"The centepied its regenerated at the start of a new floor"),

		spa = makeDesc(
			"Genera un cienpies alrededor de Isaac que lo protegera de projectiles enemigos",
			"Cada seccione del cienpies tomara se destruira despues de tomar cierta cantidad de golpe",
			"El cienpies desaparecerá si tiene 4 o menos secciones",
			"El cienpies se regenerara al inicio de cada piso"),
	}, Name = {
		en_us = "Centepied",
		spa = "Cienpies",
	}},

	{ID = Mod.Enum.Item.LIL_EMBRION, Desc = {
		en_us = makeDesc(
			"Gives a familiar that follows Isaac",
			"The familiar loosely copied half of Isaac tear rate",
			"The slower it is the tear rate is the more tears it shoots"),

		spa = makeDesc(
			"Da un familiar que sigue a Isaac",
			"El familair vagamente copia la mitad de la velocidad de disparo de Isaac",
			"Cuanto más lento la velocidad de disparo más lágrimas disparara"),
	}, Name = {
		en_us = "Lil Embrion",
		spa = "Pequeño Embrión",
	}},

	{ID = Mod.Enum.Item.FRIENDLY_BITE, Desc = {
		en_us = makeDesc(
			"Double-tapping a fire key make Isaac bite",
			"Per each enemy kill by the bite",
			"{{ArrowUp}} {{Damage}} + 0.5 Temporary Damage",
			"The damage caps at + 7.5 Damage",
			"The bite does 150% of Isaac damage",
			"Getting hit recharges the bite"),

		spa = makeDesc(
			"Tocar dos veces la tecla de disparo hara que Isaac muerda",
			"Por cada enemigo matado por la mordida",
			"{{ArrowUp}} {{Damage}} + 0.5 Daño Temporal",
			"El daño se limita a + 7.5 Daño",
			"La mordida hace 150% del daño de Isaac",
			"Ser golpeado recarga la mordida"),
	}, Name = {
		en_us = "Friendly Bite",
		spa = "Mordida Amistosa",
	}},
	{ID = Mod.Enum.Item.FRIENDLY_BITE_ALT, Desc = {
		en_us = makeDesc(
			"On use makes Isaac bite on his current fire or moving direction",
			"Per each enemy kill by the bite",
			"{{ArrowUp}} {{Damage}} + 0.5 Temporary Damage",
			"The damage caps at + 7.5 Damage",
			"The bite does 150% of Isaac damage"),

		spa = makeDesc(
			"Al usarlo hace que Isaac muerda hacia donde dispara o mueve",
			"Por cada enemigo matado por la mordida",
			"{{ArrowUp}} {{Damage}} + 0.5 Daño Temporal",
			"El daño se limita a + 7.5 Daño",
			"La mordida hace 150% del daño de Isaac"),
	}, Name = {
		en_us = "Friendly Bite",
		spa = "Mordida Amistosa",
	}},

	{ID = Mod.Enum.Item.LIL_BITER, Desc = {
		en_us = makeDesc(
			"Give a familiar that follow Isaac",
			"The familiar will automatically target the closest enemy to them",
			"When the enemy is close enough it will bite them and any thing close to them",
			"Each enemy kill by the familiar it will give it small damage boost"),

		spa = makeDesc(
			"Da un familiar que sigue a Isaac",
			"El familiar apunta automáticamente al enemigo mas cercano al familiar",
			"Mordera cuando el enemigo este lo suficientemente cerca dañando al enemigo y todo proximo a el",
			"Cada enemigo matado por el familiar le dará un pequeño aumento de daño"),
	}, Name = {
		en_us = "Lil Biter",
		spa = "Pequeño Mordedor",
	}},

	{ID = Mod.Enum.Item.LIL_COW, Desc = {
		en_us = makeDesc(
			"Give a familiar that moves around the room blocking enemies projectiles",
			"Isaac can explode the familiar to give them 3 Hearts",
			"The familiar revivies after clearing 10 rooms or when entering a new floor",
			"It gives 1 Soul Hearts if Isaac doesn't have space"),
		
		spa = makeDesc(
			"Da un familiar que se mueve por el cuarto bloqueando projectiles enemigos",
			"Isaac pude explotar al familiar para curarse 3 corazones",
			"El familiar revive depues de limpiar 10 cuartos o al entrar a un nuevo piso",
			"Da un Corazón de Alma si Isaac no tiene espacio"),
	}, Name = {
		en_us = "Lil Cow",
		spa = "Pequeña Vaca",
	}},
}

for _, data in ipairs(itemsDesc) do
	for leng, desc in pairs(data.Desc) do
		EID:addCollectible(data.ID, desc, (data.Name[leng] or data.Name.en_us), leng)
	end
end




local trinketsDesc = {
	{ID = Mod.Enum.Trinket.WEIRD_CANDY, Desc = {
		en_us = "Familiars do 20% more damage",
		spa = "Familiares hacen 20% más daño",
	}, Name = {
		en_us = "Weird Candy",
		spa = "Caramelo Raro",
	}},

	{ID = Mod.Enum.Trinket.EGG, Desc = {
		en_us = makeDesc(
			"Clearing a room has a 2% to gives a random permanent familiar",
			"The trinket is remove on effect"),
		
		spa = makeDesc(
			"Limpiar un cuarto tiene un 2% de dar un familiar de forma permanente",
			"El trinket se removera cuando eso suceda"),
	}, Name = {
		en_us = "Egg",
		spa = "Huevo",
	}},
	
	{ID = Mod.Enum.Trinket.STRANGE_STONE, Desc = {
		en_us = "When entering a unclear room has a 33% to gives a random familiar for the current room",
		spa = "Al entrar a un cuarto con enemigos tiene un 33% de dar un familiar por la duración del cuarto",
	}, Name = {
		en_us = "Strange Stone",
		spa = "Piedra Extraña",
	}},
}

for _, data in ipairs(trinketsDesc) do
	for leng, desc in pairs(data.Desc) do
		EID:addTrinket(data.ID, desc, (data.Name[leng] or data.Name.en_us), leng)
	end
end


local trinketMultData = {
	{ID = Mod.Enum.Trinket.WEIRD_CANDY,
		Text = {
			en_us = { "Familiars does {{ColorGold}}36{{CR}}% more damage", "Familiars does {{ColorGold}}36{{CR}}% more damage", "Familiars does {{ColorGold}}49{{CR}}% more damage" },
			spa = { "Familiares hacen {{ColorGold}}36{{CR}}% más daño", "Familiares hacen {{ColorGold}}36{{CR}}% más daño", "Familiares hacen {{ColorGold}}49{{CR}}% más daño" },
		},
		ExtraGoldenData = { fullReplace = true }
	},
	{ID = Mod.Enum.Trinket.EGG,
		Text = {
			en_us = {
				makeDesc(
					"Clearing a room as a 2% to gives {{ColorGold}}2{{CR}} random permanent familiars",
					"The trinket is remove on effect"),

				makeDesc(
					"Clearing a room as a 2% to gives a random permanent familiar",
					"The trinket is remove on effect"),

				makeDesc(
					"Clearing a room as a 2% to gives {{ColorGold}}2{{CR}} random permanent familiars",
					"The trinket is remove on effect"),
			},
			spa = {
				makeDesc(
					"Limpiar un cuarto tiene un 2% de dar {{ColorGold}}2{{CR}} familiares de forma permanente",
					"El trinket se removera cuando eso suceda"),

				makeDesc(
					"Limpiar un cuarto tiene un 2% de dar un familiar de forma permanente",
					"El trinket se removera cuando eso suceda"),

				makeDesc(
					"Limpiar un cuarto tiene un 2% de dar {{ColorGold}}2{{CR}} familiares de forma permanente",
					"El trinket se removera cuando eso suceda"),
			},
		},
		ExtraGoldenData = { fullReplace = true }
	},
	{ID = Mod.Enum.Trinket.STRANGE_STONE,
		Text = {
			en_us = {
				"When entering a unclear room has a 33% to gives {{ColorGold}}2{{CR}} random familiars for the current room",
				"When entering a unclear room has a 33% to gives {{ColorGold}}2{{CR}} random familiars for the current room",
				"When entering a unclear room has a 33% to gives {{ColorGold}}3{{CR}} random familiars for the current room",
			},
			en_us = {
				"Al entrar a un cuarto con enemigos tiene un 33% de dar {{ColorGold}}2{{CR}} familiares por la duración del cuarto",
				"Al entrar a un cuarto con enemigos tiene un 33% de dar {{ColorGold}}2{{CR}} familiares por la duración del cuarto",
				"Al entrar a un cuarto con enemigos tiene un 33% de dar {{ColorGold}}3{{CR}} familiares por la duración del cuarto",
			},
		},
		ExtraGoldenData = { fullReplace = true }
	},
}

for _, data in ipairs(trinketMultData) do
	for leng, text in pairs(data.Text) do
		EID.descriptions[leng].goldenTrinketEffects[data.ID] = text
	end
	if data.ExtraGoldenData then
		EID.GoldenTrinketData[data.ID] = data.ExtraGoldenData
	end
end



local cardsDesc = {
	{ID = Mod.Enum.Card.SACRIFICIAL_DAGGER, Desc = {
		en_us = makeDesc(
			"Spawns coins that their value amount 15 coins",
			"Removes a random familiar item from Isaac",
			"Quality 0 familiars spawns 10 coins",
			"Quality 4 familiars spawns 20 coins",
			"Spawns a Sacrificial Dagger if Isaac doesn't have familiars"),
		
		spa = makeDesc(
			"Genera monedas que su valor se amontone a 15 monedas",
			"Remueve un objeto de familiar que Isaac tenga",
			"Familiares de calidad 0 generan 10 monedas",
			"Familiares de calidad 4 generan 20 monedas",
			"Genera una Daga Sacrificial si Isaac no tiene familiares"),
	}, Name = {
		en_us = "Sacrificial Dagger",
		spa = "Daga Sacrificial",
	}},

	{ID = Mod.Enum.Card.SOUL_OF_GELLO, Desc = {
		en_us = makeDesc(
			"{{ArrowUp}} {{Damage}} + 1 Temporary Damage",
			"Per each familiar collectible",
			"{{ArrowUp}} {{Damage}} + 0.5 Temporary Damage",
			"Has a 33% to spawn a Soul of Gello on use"),

		spa = makeDesc(
			"{{ArrowUp}} {{Damage}} + 1 Daño Temporal",
			"Por cada objeto de familiar",
			"{{ArrowUp}} {{Damage}} + 0.5 Daño Temporal",
			"Tiene un 33% de generar un Alma de Gello al usarlo"),
	}, Name = {
		en_us = "Soul of Gello",
		spa = "Alma de Gello",
	}},
}

for _, data in ipairs(trinketsDesc) do
	for leng, desc in pairs(data.Desc) do
		EID:addCard(data.ID, desc, (data.Name[leng] or data.Name.en_us), leng)
	end
end




local taintedGelloBirthrightAppeal = {
	en_us = "#The effect is different to other classes",
}

local birthrightTab = {
	{ID = Mod.Enum.Character.GELLO, Desc = {
			en_us = makeDesc(
				"Upgrades Gellos bite",
				"{{Blank}} The bite area is +50% bigger",
				"{{Blank}} Does +50% Damage",
				"{{Blank}} Gains 50% more damage when killing an enemy"),

			spa = makeDesc(
				"Mejora la modida de Gello",
				"{{Blank}} El area de mordida es +50% mas grande",
				"{{Blank}} Hace +50% de Daño",
				"{{Blank}} Gana 50% más de daño cuando mata a un enemigo"),
		},
		Info = {
			en_us = makeDesc(
				"Double-tapping a fire key make Gello bite",
				"Per enemy kill in the bite zone",
				"{{ArrowUp}} {{Damage}} + 0.5 Temporary Damage",
				"The damage caps at + 7.5 Damage",
				"The bite does 150% of Gello damage"),

			spa = makeDesc(
				"Tocar dos veces la tecla de disparo hara una mordida",
				"Por cada enemigo matado por la mordida",
				"{{ArrowUp}} {{Damage}} + 0.5 Daño Temporal",
				"El daño se limita a + 7.5 Daño",
				"La mordida hace 150% del daño de Gello"),
		}
	},

	{ID = Mod.Enum.Character.GELLO_B1, Desc = {
		en_us = "The bite does 216% of Gellos damage",
		spa = "La mordida hace 216% del daño de Gello",
	}, Info = {
		en_us = makeDesc(
			"Double-tapping a fire key make Gello bite",
			"Per enemy kill in the bite zone",
			"{{ArrowUp}} {{Damage}} + 0.5 Temporary Damage",
			"The damage caps at + 7.5 Damage",
			"The bite does 165% of Gello damage"),

		spa = makeDesc(
			"Tocar dos veces la tecla de disparo hara una mordida",
			"Por cada enemigo matado por la mordida",
			"{{ArrowUp}} {{Damage}} + 0.5 Daño Temporal",
			"El daño se limita a + 7.5 Daño",
			"La mordida hace 165% del daño de Gello"),
	}},

	{ID = Mod.Enum.Character.GELLO_B2, Desc = {
		en_us = "Entering a unclear room#Gives a random wacky passive item",
		spa = "Al entrar a un cuarto con enemigos#Da un objeto pasivo con algun efecto alocado",
	}, Info = {
		en_us = "Tears have a 0 to 3 tears effect#This also affects bombs, lasers and knifes",
		spa = "Lágrimas tienen de 0 a 3 efectos#Esto tambien afecta a las bombas, láseres y cuchillos",
	}},

	{ID = Mod.Enum.Character.GELLO_B3, Desc = {
		en_us = "The shock wave does 33% more damage",
		spa = "La onda hace 33% más daño",
	}, Info = {
		en_us = makeDesc(
			"Has innate {{Collectible"..CollectibleType.COLLECTIBLE_WAFER.."}} Waffer",
			"{{Chargeable}} Shooting fill a charge bar",
			"{{Blank}} On release makes a shock wave that confuse and damage nearby enemies"),

		spa = makeDesc(
			"Tiene la {{Collectible"..CollectibleType.COLLECTIBLE_WAFER.."}} Hostia de forma inata",
			"{{Chargeable}} Disparar carga una barra",
			"{{Blank}} Al liberarlo hace una onda que confunde y daña a enemigos cercanos"),
	}},

	{ID = Mod.Enum.Character.GELLO_B4, Desc = {
		en_us = "Dashing through enemies does 133% + 2.5 of Gellos damage",
		spa = "Dashear atraves de enemigos hace 133% + 2.5 daño de Gello",
	}, Info = {
		en_us =  makeDesc(
			"{{Chargeable}} Shooting fill a charge bar",
			"{{Blank}} On release makes Gello dash to the direction it was moving",
			"{{Blank}} If Gello is not moving it dashes to the direction it was shooting"),
		spa =  makeDesc(
			"{{Chargeable}} Disparar carga una barra",
			"{{Blank}} Al liberarlo hace que Gello haga un dash a la dirección que estaba moviendo",
			"{{Blank}} Si Gello no se estaba moviendo hace el dash en la dirección en la que estaba disparando"),
	}},

	{ID = Mod.Enum.Character.GELLO_B5, Desc = {
		en_us = "When entering a unclear room charms 3 random enemies",
		spa = "Al entrar a un cuarto con enemigos encanta a 3 de ellos",
	}, Info = {
		en_us = makeDesc(
			"Has a 5% to shoot a charming tear",
			"{{Chargeable}} Shooting charge a bar",
			"{{Blank}} When letting go charm nearby enemies",
			"How long the enemy stays charm depends by how close it was to Gello"),

		spa = makeDesc(
			"Tiene un 5% de disparar una lágrima encantadora",
			"{{Chargeable}} Disparar carga una barra",
			"{{Blank}} Al dejarlo ir encata a enemigos cercanos",
			"Que tanto se queda el enemigo encantado depende de que tan cerca estaba a Gello"),
	}},

	{ID = Mod.Enum.Character.GELLO_B6, Desc = {
		en_us = "It can charge a threeth time to make a Mama Mega explosion#This make 4 hearts of damage to Gello",
		spa = "Puede cargar una tercera vez para hacer una explosión de Mama Mega#Esto hace 4 Corazones de daño a Gello",
	}, Info = {
		en_us = makeDesc(
			"Has immunity to fire damage",
			"{{Chargeable}} Shooting charge a bar",
			"{{Blank}} When letting go it makes an explosion that doesn't damage Gello and obstacles",
			"{{Blank}} It can be charge a secound time to that makes a bigger explosion that can destroid obstacles but does a full heart of damage to Gello"),

		spa = makeDesc(
			"Tiene inmunidad al daño de fuego",
			"{{Chargeable}} Disparar carga una barra",
			"{{Blank}} Al dejarlo ir hace una explosión que no daña a Gello y a los obstaculos",
			"{{Blank}} Esto puede cargarse una segunda vez para hacer una explosión mayor que puede destruir obstaculos pero hace un corazón entero de daño a Gello"),
	}},

	{ID = Mod.Enum.Character.GELLO_B7, Desc = {
		en_us = makeDesc(
			"Entering a new room has a 33% to give a sigle use {{Collectible"..CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER.."}} We Need To Go Deeper",
			"Using it on a decorative tile spawns a skeleton" ),

		spa = makeDesc(
			"Al entrar a un nuevo cuarto tiene un 33% de dar {{Collectible"..CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER.."}} Necesitamos Ir Más Profundo de un solo uso",
			"Genera un esqueleto al usarlo en una decoración del suelo" ),
	}, Info = {
		en_us = makeDesc(
			"Killing an enemy has a 50% to spawn a friendly skeleton",
			"{{Blank}} The skeleton has the same health of the killed enemy",
			"{{Blank}} Doesn't spawn more skeletons if the total health points is 100 or more"),

		spa = makeDesc(
			"Matar a un enemigo tiene un 50% de generar un esqueleto amistoso",
			"{{Blank}} El esqueleto tiene la misma vida que el enemigo matado",
			"{{Blank}} No genera más esqueletos si la cantidad de vida se suma a 100 o más"),
	}},

	{ID = Mod.Enum.Character.GELLO_B8, Desc = {
		en_us = "TODO",
	}, Info = {
		en_us = makeDesc(
			"Has innate Money = Power",
			"Killing an enemy has a 20% of spawn a coin"),
	}},

	{ID = Mod.Enum.Character.GELLO_B9, Desc = {
		en_us = "Friendlys can be over heal to a 33% over their max health",
		spa = "Enemigos amistosos pueden ser curados un 33% sobre su vida maxima",
	}, Info = {
		en_us = makeDesc(
			"Friendly enemies very close to Gello heals",
			"When an enemy die has a 20% to revive as a friendly"),

		spa = makeDesc(
			"Enemigos amistosos muy cercano pueden ser curados por Gello",
			"Cuando un enemigo muere tiene un 20% de que reviva siendo amistoso"),
	}},

	{ID = Mod.Enum.Character.GELLO_B10, Desc = {
		en_us = "The plants do 35% more damage",
		spa = "Las plantas hacen 35% maś daño",
	}, Info = {
		en_us = makeDesc(
			"On unclear rooms",
			"{{Blank}} Spawns plants in the room",
			"If an enemy goes to a tile with a plants they get trap",
			"The plant retains and damage the enemy for 5 seconds"),

		spa = makeDesc(
			"En un cuarto con enemigos",
			"{{Blank}} Genera plantas en el cuarto",
			"Si un enemigo va a un suelo con una planta el será atrapado",
			"La planta retendra y dañara al enemigo por 5 segundos"),
	}},

	{ID = Mod.Enum.Character.GELLO_B11, Desc = {
		en_us = "Increase the vomit duration but also the charge amount",
		spa = "Aunmenta la duración del vomito pero tambien aunmenta la cantidad de carga",
	}, Info = {
		en_us = makeDesc(
			"Tears have a 10% to be poisoning and leave a green creep",
			"{{Chargeable}} Shooting will charge a bar",
			"{{Blank}} On releace when is fully charge will make Gello vomit green tears for 7 seconds",
			"When it gets hit by an enemy it will poison them"),

		spa = makeDesc(
			"Lágrimas tienen un 10% de ser venenosar y dejar un fluido verde",
			"{{Chargeable}} Disparar carga una barra",
			"{{Blank}} Al liberarlo cuando esta totalmente cargado hará que Gello vomite lágrimas verdes por 7 segundos",
			"Cuando es golpeado por un enemigo lo envenenara"),
	}},

	{ID = Mod.Enum.Character.GELLO_B12, Desc = {
		en_us = "Shoots rocky tears that can destroids obstacles",
		spa = "Dispara lágrimas rocosas que pueden destruir obstaculos",
	}, Info = {
		en_us = makeDesc(
			"When entering to a new room with rocks",
			"{{Blank}} Some rocks become special",
			"{{Blank}} Breaking these rocks will spawn 1 to 3 pickups or a chest",
			"Using {{Collectible"..CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER.."}} We Need to go Deeper on a decoration will generate 1 to 3 pickups"),

		spa = makeDesc(
			"Cuando entra a un nuevo cuarto con piedras",
			"{{Blank}} Algunas piedras se volveran especiales",
			"{{Blank}} Romper estas piedras generara 1 a 3 recolectables o un cofre",
			"Usar {{Collectible"..CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER.."}} Necesitamos Ir Más Profundo sobre la decoración del suelo genera 1 a 3 recolectables"),
	}},

	{ID = Mod.Enum.Character.GELLO_B13, Desc = {
		en_us = "Copies the birthright effects of the other classes",
		spa = "Copia el efecto de Primogenitura de otras clases",
	}, Info = {
		en_us = makeDesc(
			"Copies the stats of other classes",
			"Copies the ability of one of the other classes",
			"Has random stats multipliers"),

		spa = makeDesc(
			"Copia las estadisticas de otras clases",
			"Copia las habilidades de otras clases",
			"Tiene multiplicadores de estadisticas aletoreo"),
	}},
}

for i, data in ipairs(birthrightTab) do
	local name = "Gello"
	if i > 1 then name = "Tainted "..name end

	for leng, desc in pairs(data.Desc) do
		if i > 1 then
			desc = desc .. (taintedGelloBirthrightAppeal[leng] or "")
		end
		EID:addBirthright(data.ID, desc, name, leng)
	end
	for leng, desc in pairs(data.Info) do
		EID:addCharacterInfo(data.ID, desc, name, leng)
	end
end




local bffsSynergies = {
	{ ID = "5.100."..Mod.Enum.Item.BEELZEBUB,   Change = { 
		en_us = "Makes its rock wave radius bigger",
		spa = "Hace el radio de la onda más grande",
	}},
	{ ID = "5.100."..Mod.Enum.Item.LARRY_JR_JR, Change = {
		en_us = "Doubles damage",--#{{Blank}} Blue : Makes bigger creeps#{{Blank}} Green : Double their tear damege#{{Blank}} Rock : Double rock wave radius",
		spa = "Hace doble de daño",--#{{Blank}} Azul : Hace charcos más grandes#{{Blank}} Verde : Duplica el daño de sus lágrimas#{{Blank}} Rocoso : Dobla el radio de la onda",
	}},
	{ ID = "5.100."..Mod.Enum.Item.LIL_BITER,   Change = {
		en_us = "Bigger Bites#Doubles bite damage",
		spa = "Mordidas más grandes#Dobla el daño de la mordida",
	}},
	{ ID = "5.100."..Mod.Enum.Item.LIL_COW,     Change = {
		en_us = {"10", "7"},
		spa = {"10", "7"},
	}},
	{ ID = "5.100."..Mod.Enum.Item.LIL_EMBRION, Change = {
		en_us = "Double tear damage",
		spa = "Dobla el daño de las lágrimas",
	}},
}

for _, data in ipairs(bffsSynergies) do
	for leng, change in pairs(data.Change) do
		EID.descriptions[leng].BFFSSynergies[data.ID] = change
	end
end


local gelloSynergy = {
	en_us = "Reduce bite cooldown",
	spa = "Reduce la carga de la mordida",
}
local synergyID = "5.100."..tostring(Mod.Enum.Item.FRIENDLY_BITE).." (Gello Character)"
for leng, text in pairs(gelloSynergy) do
	EID.descriptions[leng].ConditionalDescs[synergyID] = text
end
EID:AddPlayerConditional({Mod.Enum.Item.FRIENDLY_BITE}, {Mod.Enum.Character.GELLO}, synergyID, nil, false)

local semiClassicGelloSynergy = {
	en_us = {"{{ArrowUp}} {{Damage}} x1.25 Damage multiplier"},
	spa = {"{{ArrowUp}} {{Damage}} x1.25 multiplicador de Daño"},
}
local bffsSynergy = "5.100."..tostring(CollectibleType.COLLECTIBLE_BFFS).." (Gello Character)"
for leng, text in pairs(semiClassicGelloSynergy) do
	EID.descriptions[leng].ConditionalDescs[bffsSynergy] = text
end

EID:AddConditional({CollectibleType.COLLECTIBLE_BFFS}, function()
	return Mod.GetSetting("GelloFamiliarConsumeType") == 1 and EID:ConditionalCharCheck(Mod.Enum.Character.GELLO, false)
end, bffsSynergy, {
	variableText = "{{NameOnlyI" .. Mod.Enum.Character.GELLO .. "}}",
	bulletpoint = "Player" .. Mod.Enum.Character.GELLO
})

for _, charID in ipairs({
	Mod.Enum.Character.GELLO_B1,
	Mod.Enum.Character.GELLO_B2,
	Mod.Enum.Character.GELLO_B3,
	Mod.Enum.Character.GELLO_B4,
	Mod.Enum.Character.GELLO_B5,
	Mod.Enum.Character.GELLO_B6,
	Mod.Enum.Character.GELLO_B7,
	Mod.Enum.Character.GELLO_B8,
	Mod.Enum.Character.GELLO_B9,
	Mod.Enum.Character.GELLO_B10,
	Mod.Enum.Character.GELLO_B11,
	Mod.Enum.Character.GELLO_B12,
	Mod.Enum.Character.GELLO_B13,
}) do
	EID:AddConditional({CollectibleType.COLLECTIBLE_BFFS}, function()
		return Mod.GetSetting("TainteGelloEatsFams") and EID:ConditionalCharCheck(charID, false)
	end, bffsSynergy, {
		variableText = "{{NameOnlyI" .. charID .. "}}",
		bulletpoint = "Player" .. charID
	})
end


local lilHamsterCarBattery = {
	en_us = {makeDesc(
		"{{CR}}Car Battery:",	
		"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER.."}} Does {{BlinkYellowGreen}}50{{CR}} points of damage to all enemies in the room",
		"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_2.."}} {{BlinkYellowGreen}}Does 20 points of damage{{CR}} and slows all enemies in the room 5 seconds",
		"{{Blank}} On death they freeze",
		"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_3.."}} Sets all enemies in the room on fire for 5 seconds",
		"{{Blank}} {{BlinkYellowGreen}}Increase the fire damage{{CR}}",
		"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_4.."}} Heals Isaac for {{BlinkYellowGreen}}2 Hearts{{CR}}",
		"{{Blank}} If Isaac doesn't have space for Hearts it gives {{BlinkYellowGreen}}2 Soul Hearts{{CR}}",
		"Swaps the item to one of these")},

	spa = {makeDesc(
		"{{CR}}Bateria de Auto:",
		"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER.."}} Hace {{BlinkYellowGreen}}50{{CR}} puntos de daño a todos los enemigos en el cuarto",
		"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_2.."}} {{BlinkYellowGreen}}Hace 20 puntos de daño{{CR}} y relentiza a todos los enemigos en el cuarto por 5 segundos",
		"{{Blank}} Cuando se mueren se congelan",
		"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_3.."}} Prende a todos los enemigos en fuego por 5 segundos",
		"{{Blank}} {{BlinkYellowGreen}}Aumenta el daño del fuego{{CR}}",
		"{{Collectible"..Mod.Enum.Item.LIL_HAMSTER_4.."}} Cura {{BlinkYellowGreen}}2 Corazones{{CR}}",
		"{{Blank}} Si Isaac no tiene espacio para corazones, le da {{BlinkYellowGreen}}2 Corazones de Alma{{CR}}",
		"Cambia el objeto a uno de estos")},
}
for leng, text in pairs(lilHamsterCarBattery) do
	EID.descriptions[leng].carBattery[Mod.Enum.Item.LIL_HAMSTER] = text
	EID.descriptions[leng].carBattery[Mod.Enum.Item.LIL_HAMSTER_2] = text
	EID.descriptions[leng].carBattery[Mod.Enum.Item.LIL_HAMSTER_3] = text
	EID.descriptions[leng].carBattery[Mod.Enum.Item.LIL_HAMSTER_4] = text
end

if EID.blackFeatherItems then
	EID.blackFeatherItems[Mod.Enum.Item.CURSED_PLUSHIE] = true
elseif EID.BlackFeatherItems then
	EID.BlackFeatherItems[Mod.Enum.Item.CURSED_PLUSHIE] = true
end
if EID.CarBatteryNoSynergy then
	EID.CarBatteryNoSynergy[Mod.Enum.Item.FETAL_JAR] = true
end


EID:addEntity(6, Mod.Enum.Slot.MISSING_POSTER, 1, "Missing Post (Beggar)", "", "en_us")
EID:addEntity(6, Mod.Enum.Slot.MISSING_POSTER, 1, "Post Perdido (Mendigo)", "", "spa")

GelloCharMod.EID_MissingPost = {
	en_us = {
		error = "Unknown familiar",
		[0] = makeDesc(
			"This familiar is may be granted by entering a new room"
		),
		makeDesc(
			"This familiar is may spawn in a hostile room and will attack Isaac",
			"It will follow Isaac when defeated"
		),
		makeDesc(
			"This familiar is may spawn in new room with rocks",
			"It will follow Isaac after staying close to it for some time or blowing its cover"
		),
		makeDesc(
			"This familiar is may spawn in new room",
			"It will follow Isaac after it gets close to him",
			"If the familiar spawn but didn't start following Isaac, it will wait for Isaac in the center of the room"
		),
	},
	spa = {
		error = "Familiar desconocido",
		[0] = makeDesc(
			"Este familiar puede que se lo den a Isaac al entrar a un nuevo cuarto"
		),
		makeDesc(
			"Este familiar puede que aparesca al entrar a un cuarto hostil y atacara a Isaac",
			"Seguira a Isaac despues de que sea derrotado"
		),
		makeDesc(
			"Este familiar puede que aparesca al entrar a un nuevo cuarto con piedras",
			"Empezara a seguir a Isaac despues de que se quede cerca de el por un tiempo o al explotar su covertura"
		),
		makeDesc(
			"Este familiar puede que aparesca al entrar a un nuevo cuarto",
			"Empezara a seguir a Isaac cuando se acerque lo suficiente",
			"Si el familiar aparecio pero no empezo a seguir a Isaac, el esperará por Isaac en el centro del cuarto"
		),
	}
}

local posterSave = Mod.SaveHandler.Save("MissingPost_Quest")
EID:addDescriptionModifier(
	"Missing Post Gello Desc Mod",
	function (descObj)
		if descObj.ObjType ~= 6 or descObj.ObjVariant ~= Mod.Enum.Slot.MISSING_POSTER or descObj.ObjSubType ~= 1 then return false end
		local slot = descObj.Entity
		return slot ~= nil and slot:GetSprite():IsPlaying("Idle")
	end,
	function (descObj)
		local leng = EID:getLanguage()
		local descs = Mod.EID_MissingPost[leng] or Mod.EID_MissingPost.en_us
		local data = posterSave:Get({})
		local famSub = data.FamSubType
		local desc = famSub and descs[famSub] or descs.error

		EID:appendToDescription(descObj, desc)

		return descObj
	end
)


local lilHamsterNextTab = {
	[Mod.Enum.Item.LIL_HAMSTER] = Mod.Enum.Item.LIL_HAMSTER_2,
	[Mod.Enum.Item.LIL_HAMSTER_2] = Mod.Enum.Item.LIL_HAMSTER_3,
	[Mod.Enum.Item.LIL_HAMSTER_3] = Mod.Enum.Item.LIL_HAMSTER_4,
}

local lilHamsterItemOverview = function(descObj, player, inOverview)
	if not inOverview then return end
	local desc = ""
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
		desc = EID:getDescriptionEntry("carBattery", "{{Collectible"..Mod.Enum.Item.LIL_HAMSTER.."}}", true)
		if desc == nil then desc = descObj.Description
		else desc = desc[1] end
	else
		desc = descObj.Description
	end

	local _, startPos = string.find(desc, "{{Collectible".. descObj.ObjSubType .."}} ")
	if not startPos then return end
	
	local newDesc = string.sub(desc, startPos)
	local nextID = lilHamsterNextTab[tonumber(descObj.ObjSubType)]
	local endPos

	if nextID ~= nil then
		endPos = string.find(newDesc, "#{{Collectible".. nextID .."}}")
	else
		endPos = string.find(newDesc, "#%a")
	end
	if not endPos then return end

	newDesc = string.sub(newDesc, 1, endPos-1)
	EID:ItemReminderAddResult(descObj, newDesc, inOverview)
	return true
end

EID.ItemReminderDescriptionModifier[ ("5.100."..Mod.Enum.Item.LIL_HAMSTER) ] = {modifierFunction = lilHamsterItemOverview}
EID.ItemReminderDescriptionModifier[ ("5.100."..Mod.Enum.Item.LIL_HAMSTER_2) ] = {modifierFunction = lilHamsterItemOverview}
EID.ItemReminderDescriptionModifier[ ("5.100."..Mod.Enum.Item.LIL_HAMSTER_3) ] = {modifierFunction = lilHamsterItemOverview}
EID.ItemReminderDescriptionModifier[ ("5.100."..Mod.Enum.Item.LIL_HAMSTER_4) ] = {modifierFunction = lilHamsterItemOverview}