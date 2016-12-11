/// @description scrSaveGame(savePosition)
/// Saves the game
/// argument0 - sets whether the game should save the player's current location or just save the deaths/time

var savePosition = argument0;

// Save the player's current location variables if the script is currently set to (we don't want to save the player's location if we're just updating death/time)
if (savePosition) {
    global.saveRoom = room_get_name(room);
    global.savePlayerX = objPlayer.x;    
    global.savePlayerY = objPlayer.y;
    global.saveGrav = global.grav;
    
    // Check if the player is saving inside of a wall or in the ceiling when the player's position is floored to prevent save locking
    with (objPlayer) {
        if (!place_free(floor(global.savePlayerX),global.savePlayerY)) {
            global.savePlayerX += 1;
        }
        
        if (!place_free(global.savePlayerX,floor(global.savePlayerY))) {
            global.savePlayerY += 1;
        }
        
        if (!place_free(floor(global.savePlayerX),floor(global.savePlayerY))) {
            global.savePlayerX += 1;
            global.savePlayerY += 1;
        }
    }
    
    // Floor the player's position to match standard engine behavior
    global.savePlayerX = floor(global.savePlayerX);
    global.savePlayerY = floor(global.savePlayerY);
    
	//TODO: check if there's a better way of copying these
    for (var i = 0; i < SECRET_ITEM_TOTAL; i++) {
        global.saveSecretItem[i] = global.secretItem[i];
    }
    
    for (var i = 0; i < BOSS_ITEM_TOTAL; i++) {
        global.saveBossItem[i] = global.bossItem[i];
    }
    
    global.saveGameClear = global.gameClear;
}

// Create a map for save data
var saveMap = ds_map_create();

ds_map_add(saveMap,"deaths",global.deaths);
ds_map_add(saveMap,"time",global.time);
ds_map_add(saveMap,"timeMicro",global.timeMicro);

ds_map_add(saveMap,"difficulty",global.difficulty);
ds_map_add(saveMap,"saveRoom",global.saveRoom);
ds_map_add(saveMap,"savePlayerX",global.savePlayerX);
ds_map_add(saveMap,"savePlayerY",global.savePlayerY);
ds_map_add(saveMap,"saveGrav",global.saveGrav);

for (var i = 0; i < SECRET_ITEM_TOTAL; i++) {
    ds_map_add(saveMap,"saveSecretItem["+string(i)+"]",global.saveSecretItem[i]);
}

for (var i = 0; i < BOSS_ITEM_TOTAL; i++) {
    ds_map_add(saveMap,"saveBossItem["+string(i)+"]",global.saveBossItem[i]);
}

ds_map_add(saveMap,"saveGameClear",global.saveGameClear);

// Add MD5 hash to verify saves and make them harder to hack
ds_map_add(saveMap,"mapMd5",md5_string_unicode(ds_map_write(saveMap)+MD5_STR_ADD));

// Save the map to a file

var f = file_text_open_write("Data\save"+string(global.saveNum));
    
file_text_write_string(f,base64_encode(ds_map_write(saveMap))); // Write map to the save file with base64 encoding
    
file_text_close(f);

// Destroy the map
ds_map_destroy(saveMap);