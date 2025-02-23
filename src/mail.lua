-- um_area_forsale/src/mail.lua
-- (Optionally) send mails
--[[
    Copyright (C) 2018  Gabriel Pérez-Cerezo <gabriel@gpcf.eu>
    Copyright (C) 2024  1F616EMO

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local S = core.get_translator("um_area_forsale")

if core.get_modpath("echo") then
    echo.register_event_type("um_area_forsale:area_transaction", {
        title = S("Area Transactions"),
        handle_event = function(event)
            local pos_str = core.pos_to_string(event.pos)
            return {
                title = S("Area transaction at @1", pos_str),
                description = S("@1 areas transferred to @2 for $@3",
                    #event.list_areas, event.dest, event.amount),
                more =
                    S("We hereby notify you that an area transaction was done via the For Sale Sign at @1, " ..
                        "which was named @2. The following areas are transferred to @3:",
                        pos_str, event.description, event.dest) .. "\n\n" ..
                    um_area_forsale.area_ids_stringify(event.list_areas) .. "\n\n" ..
                    S("In exchange, you should have received $@1 from @2. Please check your account balance.",
                        event.amount, event.dest),
                onclick = echo.onclick.show_more,
                image = "um_area_forsale_sign_icon.png",
            }
        end,
    })

    function um_area_forsale.mail_to_owner(owner, dest, amount, sign_pos, list_areas, description)
        return echo.send_event_to(owner, {
            type = "um_area_forsale:area_transaction",

            dest = dest,
            amount = amount,
            pos = sign_pos,
            list_areas = list_areas,
            description = description,
        })
    end
elseif core.get_modpath("mail") then
    function um_area_forsale.mail_to_owner(owner, dest, amount, sign_pos, list_areas, description)
        local pos_str = core.pos_to_string(sign_pos)
        local msg = table.concat({
            S("Dear @1,", owner),
            "",
            S(
                "We hereby notify you that an area transaction was done via the For Sale Sign at @1, " ..
                "which was named @2. The following areas are transferred to @3:",
                pos_str, description, dest),
            "",
            um_area_forsale.area_ids_stringify(list_areas),
            "",
            S("In exchange, you should have received $@1 from @2. Please check your account balance.", amount, dest),
            "",
            S("Thank you for choosing the For Sale Sign system. If you find any Wire Transfer System bugs, " ..
                "please report them at @1.",
                "https://github.com/C-C-Minetest-Server/um_area_forsale/issues"),
            "",
            S("Yours truly,"),
            S("For Sale Sign System"),
            "",
            "",
            "*" .. S("This is an automatically sent message. Do not reply.") .. "*",
        }, "\n")

        local mail_packet = {
            from = "For Sale Sign System",
            to = owner,
            subject = S("Area transaction at @1", pos_str),
            body = msg
        }
        mail.send(mail_packet)
    end
else
    function um_area_forsale.mail_to_owner() end

    core.log("warning", "[um_area_forsale] Mail/Echo mod not found, skipping notification.")
end
