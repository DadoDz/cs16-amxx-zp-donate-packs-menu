#include <amxmodx>
#include <zombie_plague/add_commas>
//#include <zombie_plague/zp_packs_system>

#define PLUGIN "[ZP] Donate Packs Menu"
#define VERSION "1.0"
#define AUTHOR "DadoDz"

native zp_get_user_packs(index);
native zp_set_user_packs(index, packs);

new g_playername[33][32];
new g_DonateRecieverPacks[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /donatemenu", "clcmd_donate_packs_menu")

	register_concmd("DONATE_AMOUNT_PACKS", "PacksDonate")
}

public client_putinserver(id) get_user_name(id, g_playername[id], charsmax(g_playername[]));

public clcmd_donate_packs_menu(id)
{
	show_menu_dpacks(id);
	return PLUGIN_HANDLED;
}

show_menu_dpacks(id)
{
	if (!is_user_connected(id))
		return;

	static pmenu, menu[128], info[2], PacksString[16];
	add_commas(zp_get_user_packs(id), PacksString, charsmax(PacksString));
	
	format(menu, charsmax(menu), "\r[\yDonate Packs Menu\r]\d^n\y- \wCurrent\y Packs:\r %s\y -\d", PacksString)
	pmenu = menu_create(menu, "donate_packs_hand");

	for (new player = 1; player < get_maxplayers(); player++)
	{	
		if (!is_user_connected(player) || player == id)
			continue;

		format(menu, charsmax(menu), "\y•  \w%s", g_playername[player])

		info[0] = player;
		info[1] = 0;

		menu_additem(pmenu, menu, info);
	}

	menu_display(id, pmenu, 0);
}

public donate_packs_hand(id, pmenu, item)
{	
	if (item == MENU_EXIT)
	{
		menu_destroy(pmenu);
		return;
	}

	new player, access, info[2];
	menu_item_getinfo(pmenu, item, access, info, charsmax(info), _, _, access);
	player = info[0];

	if (!is_user_connected(player))
		return;

	client_cmd(id, "messagemode DONATE_AMOUNT_PACKS");
	g_DonateRecieverPacks[id] = player
	menu_destroy(pmenu);
}

public PacksDonate(sender)
{
	new receiver, packs, szAmount[32], PacksString[16];

	read_argv(1, szAmount, charsmax(szAmount));
	packs = str_to_num(szAmount);
	add_commas(packs, PacksString, charsmax(PacksString));

	receiver = g_DonateRecieverPacks[sender]

	if (!is_user_connected(receiver))
		return;
        
	if (packs <= 0)
	{
		client_print_color(sender, print_team_default, "^x04[^x01ZP^x04]^x01 Invalid value of^x03 packs^x01 to send!");
		return;
	}

	if (zp_get_user_packs(sender) < packs)
	{
		client_print_color(sender, print_team_default, "^x04[^x01ZP^x04]^x01 You are trying to send too many^x03 packs^x01!");
		return;
	}

	zp_set_user_packs(sender, zp_get_user_packs(sender) - packs);
	zp_set_user_packs(receiver, zp_get_user_packs(receiver) + packs);

	client_print_color(0, print_team_default, "^x04[^x01ZP^x04]^x03 %s^x01 donated^x04 %s packs^x01 to^x03 %s", g_playername[sender], PacksString, g_playername[receiver]);
}
