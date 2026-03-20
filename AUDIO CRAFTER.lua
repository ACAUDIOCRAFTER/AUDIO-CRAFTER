Offset+d.X,0,vp.X-VC_W),0,math.clamp(vcSP.Y.Offset+d.Y,0,vp.Y-VC_H)) end end)
    local vcMinimized=false
    vcMinBtn.MouseButton1Click:Connect(function()
        vcMinimized=not vcMinimized
        if vcMinimized then AC.TS:Create(vcPanel,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=UDim2.new(0,VC_W,0,32)}):Play()
        else AC.TS:Create(vcPanel,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=UDim2.new(0,VC_W,0,VC_H)}):Play() end
    end)
    vcClsBtn.MouseButton1Click:Connect(function() vcPanel.Visible=false; vcMinimized=false; vcPanel.Size=UDim2.new(0,VC_W,0,VC_H) end)
    local vcWarnLbl=Instance.new("TextLabel",vcPanel); vcWarnLbl.Size=UDim2.new(1,-16,0,14); vcWarnLbl.Position=UDim2.new(0,8,0,90); vcWarnLbl.BackgroundTransparency=1; vcWarnLbl.Text="! Only works on Velocity executor"; vcWarnLbl.TextColor3=AC.RED_ERR; vcWarnLbl.TextSize=9; vcWarnLbl.Font=Enum.Font.GothamBold; vcWarnLbl.TextXAlignment=Enum.TextXAlignment.Center; vcWarnLbl.ZIndex=91
    vcActBtn.MouseButton1Click:Connect(function()
        vcActBtn.Text="..."; vcActBtn.TextColor3=AC.TXT_DIM
        task.spawn(function()
            local ok,err=pcall(function()
                local vin=game:GetService("VoiceChatInternal")
                firesignal(vin.TempSetMicMutedToggleMic)
                vin:PublishPause(false)
            end)
            if ok then vcActBtn.Text="Done!"; vcActBtn.TextColor3=AC.GREEN_OK; AC.toast("VC bypass activated!",AC.GREEN_OK)
            else vcActBtn.Text="Failed"; vcActBtn.TextColor3=AC.RED_ERR; AC.toast("VC bypass failed",AC.RED_ERR) end
            task.delay(2.5,function() vcActBtn.Text="Activate"; vcActBtn.TextColor3=AC.PUR_GLOW end)
        end)
    end)
    vcMainBtn.MouseButton1Click:Connect(function()
        pcall(function() AC.clickSnd:Play() end)
        vcPanel.Visible=not vcPanel.Visible
        if vcPanel.Visible then
            local vp=AC.camera.ViewportSize; local pos=vcPanel.Position
            local cx=math.clamp(pos.X.Offset,0,vp.X-VC_W); local cy=math.clamp(pos.Y.Offset,0,vp.Y-VC_H)
            vcPanel.Position=UDim2.new(0,cx,0,cy)
        end
    end)
    AC.sectionLbl(pg,"SYSTEM",314); AC.cmdListBtn=AC.makeBtn(pg,"Command List",332,40)
    AC.sectionLbl(pg,"CREDITS",384)
    local crd=AC.makeCard(pg,402,66,AC.BG_CARD)
    local cr1=Instance.new("TextLabel",crd); cr1.Size=UDim2.new(1,-16,0,20); cr1.Position=UDim2.new(0,12,0,6); cr1.BackgroundTransparency=1; cr1.Text="AC AudioCrafter V4.79  by MelodyCrafter"; cr1.TextColor3=AC.PUR_BRIGHT; cr1.TextSize=13; cr1.Font=Enum.Font.GothamBold; cr1.TextXAlignment=Enum.TextXAlignment.Left
    local cr2=Instance.new("TextLabel",crd); cr2.Size=UDim2.new(1,-16,0,14); cr2.Position=UDim2.new(0,12,0,28); cr2.BackgroundTransparency=1; cr2.Text="Inspired by IY, SystemBroken, Empty Tools, Onyx V2, AKADMIN, Bleed"; cr2.TextColor3=AC.TXT_DIM; cr2.TextSize=10; cr2.Font=Enum.Font.Gotham; cr2.TextXAlignment=Enum.TextXAlignment.Left
    btn.MouseButton1Click:Connect(function() AC.switchTab("Misc") end)
end

-- EXTERNAL + COMMAND LIST
do
    local extSep=Instance.new("Frame",AC.sideScroll); extSep.Size=UDim2.new(1,-16,0,1); extSep.BackgroundColor3=AC.PUR_STROKE; extSep.BackgroundTransparency=0.4; extSep.LayoutOrder=90
    local extLbl=Instance.new("TextLabel",AC.sideScroll); extLbl.Size=UDim2.new(1,-16,0,16); extLbl.BackgroundTransparency=1; extLbl.Text="EXTERNAL"; extLbl.TextColor3=AC.ORANGE_W; extLbl.TextSize=9; extLbl.Font=Enum.Font.GothamBold; extLbl.TextXAlignment=Enum.TextXAlignment.Left; extLbl.LayoutOrder=91
    local iyBtn=AC.createTab("Infinite Yield",92,true)
    iyBtn.MouseButton1Click:Connect(function() AC.toast("Loading IY...",AC.ORANGE_W); task.spawn(function() pcall(function() safeRun("INF_YIELD") end) end) end)
    local CMDS={{".view","Spectate target"},{".tp [name]","TP to player"},{".cleartarget","Clear target"},{".esp","Toggle ESP"},{".fly","Toggle Fly"},{".noclip","Toggle Noclip"},{".fullbright","Toggle Fullbright"},{".shaders","Toggle Shaders"},{".baseplate","Toggle Baseplate"},{".antivoid","Toggle Anti-Void"},{".antiafk","Toggle Anti-AFK"},{".re","Respawn in place"},{".reset","Reset character"},{".minimize","Toggle GUI"},{".cmds","Command List"},{".hide [n]","Hide player"},{".unhide [n]","Unhide player"},{".rj","Rejoin server"}}
    local cp=Instance.new("Frame",AC.screenGui); cp.Size=UDim2.new(0,340,0,480); cp.Position=UDim2.new(0, math.floor(AC.camera.ViewportSize.X/2)-170, 0, math.floor(AC.camera.ViewportSize.Y/2)-240); cp.BackgroundColor3=Color3.fromRGB(10,10,10); cp.ZIndex=50; cp.Visible=false; cp.ClipsDescendants=true; Instance.new("UICorner",cp).CornerRadius=UDim.new(0,12); Instance.new("UIStroke",cp).Color=AC.PUR_STROKE
    local cph=Instance.new("Frame",cp); cph.Size=UDim2.new(1,0,0,40); cph.BackgroundColor3=Color3.fromRGB(6,6,6); cph.ZIndex=51; Instance.new("UICorner",cph).CornerRadius=UDim.new(0,12)
    local cpt=Instance.new("TextLabel",cph); cpt.Size=UDim2.new(1,-50,1,0); cpt.Position=UDim2.new(0,14,0,0); cpt.BackgroundTransparency=1; cpt.Text="  Command List"; cpt.TextColor3=AC.TXT_WHITE; cpt.TextSize=14; cpt.Font=Enum.Font.GothamBold; cpt.TextXAlignment=Enum.TextXAlignment.Left; cpt.ZIndex=52
    local cpX=Instance.new("TextButton",cph); cpX.Size=UDim2.new(0,26,0,26); cpX.Position=UDim2.new(1,-32,0.5,-13); cpX.BackgroundColor3=AC.PUR_MID; cpX.Text="X"; cpX.TextColor3=AC.TXT_WHITE; cpX.TextSize=12; cpX.Font=Enum.Font.GothamBold; cpX.ZIndex=52; Instance.new("UICorner",cpX).CornerRadius=UDim.new(1,0); cpX.MouseButton1Click:Connect(function() cp.Visible=false end)
    local cps=Instance.new("ScrollingFrame",cp); cps.Size=UDim2.new(1,-8,1,-48); cps.Position=UDim2.new(0,4,0,44); cps.BackgroundTransparency=1; cps.BorderSizePixel=0; cps.ScrollBarThickness=3; cps.ScrollBarImageColor3=AC.PUR_MID; cps.AutomaticCanvasSize=Enum.AutomaticSize.Y; cps.CanvasSize=UDim2.new(0,0,0,0); cps.ZIndex=51
    local cpl=Instance.new("UIListLayout",cps); cpl.Padding=UDim.new(0,2); local cpp=Instance.new("UIPadding",cps); cpp.PaddingTop=UDim.new(0,4); cpp.PaddingLeft=UDim.new(0,4); cpp.PaddingRight=UDim.new(0,4)
    for i,cd in ipairs(CMDS) do
        local row=Instance.new("TextButton",cps); row.Size=UDim2.new(1,0,0,42); row.BackgroundColor3=Color3.fromRGB(16,16,16); row.Text=""; row.LayoutOrder=i; row.ZIndex=52; Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local cl=Instance.new("TextLabel",row); cl.Size=UDim2.new(1,-16,0,18); cl.Position=UDim2.new(0,12,0,4); cl.BackgroundTransparency=1; cl.Text=cd[1]; cl.TextColor3=AC.PUR_BRIGHT; cl.TextSize=13; cl.Font=Enum.Font.GothamBold; cl.TextXAlignment=Enum.TextXAlignment.Left; cl.ZIndex=53
        local dl=Instance.new("TextLabel",row); dl.Size=UDim2.new(1,-16,0,14); dl.Position=UDim2.new(0,12,0,22); dl.BackgroundTransparency=1; dl.Text=cd[2]; dl.TextColor3=AC.TXT_DIM; dl.TextSize=11; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.ZIndex=53
        row.MouseEnter:Connect(function() AC.TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=AC.PUR_DARK}):Play() end); row.MouseLeave:Connect(function() AC.TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(16,16,16)}):Play() end)
    end
    local cpDrag,cpDS,cpSP=false,nil,nil
    cph.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then cpDrag=true; cpDS=i.Position; cpSP=cp.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then cpDrag=false end end) end end)
    AC.UIS.InputChanged:Connect(function(i) if cpDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-cpDS; cp.Position=UDim2.new(cpSP.X.Scale,cpSP.X.Offset+d.X,cpSP.Y.Scale,cpSP.Y.Offset+d.Y) end end)
    AC.cmdListBtn.MouseButton1Click:Connect(function() cp.Visible=not cp.Visible end)
    local hiddenChars={}
    local function handleChat(msg)
        msg=msg:lower():gsub("^%s+",""); local args={}; for w in msg:gmatch("%S+") do args[#args+1]=w end
        local cmd=args[1]; if not cmd or cmd:sub(1,1)~="." then return end
        if cmd==".view" then if AC.selectedTarget then AC.startViewing(AC.selectedTarget) end
        elseif cmd==".tp" then local n=args[2]; local tgt=AC.selectedTarget; if n then for _,p in ipairs(AC.Players:GetPlayers()) do if p.Name:lower():find(n,1,true) then tgt=p; break end end end; if tgt and tgt.Character then local r=tgt.Character:FindFirstChild("HumanoidRootPart"); local m=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if r and m then m.CFrame=r.CFrame*CFrame.new(0,0,-3); AC.toast("TP'd to "..tgt.Name) end end
        elseif cmd==".cleartarget" then AC.stopViewing(); AC.onHead=false; AC.inBp=false; AC.selectedTarget=nil; if AC.sBox then AC.sBox.Text="" end
        elseif cmd==".fly" then if AC.flyActive then AC.flyActive=false; if AC.flyConn then AC.flyConn:Disconnect(); AC.flyConn=nil end; if AC.flyBV then AC.flyBV:Destroy(); AC.flyBV=nil end; if AC.flyBG then AC.flyBG:Destroy(); AC.flyBG=nil end; if AC._flyAtt then AC._flyAtt:Destroy(); AC._flyAtt=nil end; local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=false end else AC.flyActive=true end
        elseif cmd==".noclip" then if AC.noclipConn then AC.noclipConn:Disconnect(); AC.noclipConn=nil; if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end else AC.noclipConn=AC.RS.Stepped:Connect(function() local char=AC.player.Character; if not char then return end; for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end) end
        elseif cmd==".fullbright" then local v=not(AC.Lighting.Brightness>1); AC.Lighting.Brightness=v and 2 or 1; AC.Lighting.GlobalShadows=not v; AC.Lighting.Ambient=v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127); AC.Lighting.OutdoorAmbient=v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
        elseif cmd==".re" then local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); local sv=mr and mr.CFrame; if sv then local conn2; conn2=AC.player.CharacterAdded:Connect(function(nc) conn2:Disconnect(); task.wait(0.5); local mr3=nc:WaitForChild("HumanoidRootPart",5); if mr3 then mr3.CFrame=sv; AC.toast("Respawned!",AC.GREEN_OK) end end); local hh=AC.player.Character:FindFirstChildOfClass("Humanoid"); if hh then hh.Health=0 end end
        elseif cmd==".reset" then local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end
        elseif cmd==".minimize" then if AC._uiOpen then AC.doMin() else AC.doOpen() end
        elseif cmd==".cmds" then cp.Visible=not cp.Visible
        elseif cmd==".hide" then local n=args[2]; if n then for _,p in ipairs(AC.Players:GetPlayers()) do if p.Name:lower()==n and p.Character then for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") or part:IsA("Decal") then part.LocalTransparencyModifier=1 end end; hiddenChars[p.UserId]=true end end end
        elseif cmd==".unhide" then local n=args[2]; if n then for _,p in ipairs(AC.Players:GetPlayers()) do if p.Name:lower()==n and p.Character then for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") or part:IsA("Decal") then part.LocalTransparencyModifier=0 end end; hiddenChars[p.UserId]=nil end end end
        elseif cmd==".rj" then AC.toast("Rejoining..."); task.spawn(function() task.wait(0.5); game:GetService("TeleportService"):Teleport(game.PlaceId) end)
        elseif cmd==".antivoid" then if AC.antiVoidConn then AC.antiVoidConn:Disconnect(); AC.antiVoidConn=nil else AC.antiVoidConn=AC.RS.Heartbeat:Connect(function() local mr=AC.player.Character and AC.player.Character:FindFirstChild("HumanoidRootPart"); if mr and mr.Position.Y<-200 then mr.CFrame=CFrame.new(0,10,0) end end) end
        elseif cmd==".antiafk" then if AC.afkThread then task.cancel(AC.afkThread); AC.afkThread=nil else local vu=game:GetService("VirtualUser"); AC.afkThread=task.spawn(function() while true do pcall(function() vu:Button2Down(Vector2.new(0,0),CFrame.new()); task.wait(0.1); vu:Button2Up(Vector2.new(0,0),CFrame.new()) end); task.wait(55) end end) end
        end
    end
    AC.player.Chatted:Connect(function(msg) if msg:sub(1,1)=="." then handleChat(msg) end end)
    pcall(function() local TCS=game:GetService("TextChatService"); if TCS.ChatVersion==Enum.ChatVersion.TextChatService then TCS.SendingMessage:Connect(function(msg) if msg.Text:sub(1,1)=="." then handleChat(msg.Text) end end) end end)
end

-- FACBANG PANEL
do
    local fbSep=Instance.new("Frame",AC.sideScroll); fbSep.Size=UDim2.new(1,-16,0,1); fbSep.BackgroundColor3=AC.PUR_STROKE; fbSep.BackgroundTransparency=0.4; fbSep.LayoutOrder=93
    local fbBtn=AC.createTab("FaceBang",94,true)
    if AC.tabs["FaceBang"] then
        if AC.tabs["FaceBang"].dot then AC.tabs["FaceBang"].dot.BackgroundColor3=AC.PUR_BRIGHT end
        if AC.tabs["FaceBang"].lbl then AC.tabs["FaceBang"].lbl.TextColor3=AC.PUR_GLOW end
        if AC.tabs["FaceBang"].acc then AC.tabs["FaceBang"].acc.BackgroundColor3=AC.PUR_BRIGHT end
    end
    local FB_W,FB_H=280,258
    local fbPanel=Instance.new("Frame",AC.screenGui)
    fbPanel.Size=UDim2.new(0,FB_W,0,FB_H)
    fbPanel.Position=UDim2.new(0, math.floor(AC.camera.ViewportSize.X/2)-FB_W/2, 0, math.floor(AC.camera.ViewportSize.Y/2)-FB_H/2)
    fbPanel.BackgroundColor3=AC.BG_PANEL; fbPanel.BackgroundTransparency=0
    fbPanel.ZIndex=80; fbPanel.Visible=false; fbPanel.ClipsDescendants=true
    Instance.new("UICorner",fbPanel).CornerRadius=UDim.new(0,12)
    local fbStroke=Instance.new("UIStroke",fbPanel); fbStroke.Color=AC.PUR_STROKE; fbStroke.Thickness=1.5; fbStroke.Transparency=0.2
    AC.TS:Create(fbStroke,TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Color=AC.PUR_DARK,Transparency=0.5}):Play()
    local fbHdr=Instance.new("Frame",fbPanel); fbHdr.Size=UDim2.new(1,0,0,38); fbHdr.BackgroundColor3=AC.BG_CARD; fbHdr.BackgroundTransparency=0; fbHdr.ZIndex=81; Instance.new("UICorner",fbHdr).CornerRadius=UDim.new(0,10)
    local fbHdrLine=Instance.new("Frame",fbHdr); fbHdrLine.Size=UDim2.new(1,0,0,1); fbHdrLine.Position=UDim2.new(0,0,1,-1); fbHdrLine.BackgroundColor3=AC.PUR_STROKE; fbHdrLine.BorderSizePixel=0
    local fbTitle=Instance.new("TextLabel",fbHdr); fbTitle.Size=UDim2.new(1,-50,1,0); fbTitle.Position=UDim2.new(0,14,0,0); fbTitle.BackgroundTransparency=1; fbTitle.Text="★  FaceBang"; fbTitle.TextColor3=AC.TXT_WHITE; fbTitle.TextSize=15; fbTitle.Font=Enum.Font.GothamBold; fbTitle.TextXAlignment=Enum.TextXAlignment.Left; fbTitle.ZIndex=82
    local fbMin=Instance.new("TextButton",fbHdr); fbMin.Size=UDim2.new(0,24,0,24); fbMin.Position=UDim2.new(1,-30,0.5,-12); fbMin.BackgroundColor3=Color3.fromRGB(40,40,40); fbMin.Text="-"; fbMin.TextColor3=AC.TXT_WHITE; fbMin.TextSize=16; fbMin.Font=Enum.Font.GothamBold; fbMin.ZIndex=82; Instance.new("UICorner",fbMin).CornerRadius=UDim.new(0,6)
    fbMin.MouseEnter:Connect(function() AC.TS:Create(fbMin,TweenInfo.new(0.1),{BackgroundColor3=AC.PUR_DARK}):Play() end)
    fbMin.MouseLeave:Connect(function() AC.TS:Create(fbMin,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play() end)
    fbMin.MouseButton1Click:Connect(function() fbPanel.Visible=false end)
    local fbDrag,fbDS,fbSP=false,nil,nil
    fbHdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            fbDrag=true; fbDS=i.Position; fbSP=fbPanel.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then fbDrag=false end end)
        end
    end)
    AC.UIS.InputChanged:Connect(function(i)
        if fbDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-fbDS; local vp=AC.camera.ViewportSize
            fbPanel.Position=UDim2.new(0,math.clamp(fbSP.X.Offset+d.X,0,vp.X-FB_W),0,math.clamp(fbSP.Y.Offset+d.Y,0,vp.Y-FB_H))
        end
    end)
    local fbStatus=Instance.new("TextLabel",fbPanel); fbStatus.Size=UDim2.new(1,-16,0,14); fbStatus.Position=UDim2.new(0,8,0,44); fbStatus.BackgroundTransparency=1; fbStatus.Text="Target: none  |  Status: OFF"; fbStatus.TextColor3=AC.TXT_DIM; fbStatus.TextSize=10; fbStatus.Font=Enum.Font.GothamBold; fbStatus.TextXAlignment=Enum.TextXAlignment.Left; fbStatus.ZIndex=81
    local fbBindCard=Instance.new("Frame",fbPanel); fbBindCard.Size=UDim2.new(1,-16,0,36); fbBindCard.Position=UDim2.new(0,8,0,62); fbBindCard.BackgroundColor3=AC.BG_CARD; fbBindCard.ZIndex=81; Instance.new("UICorner",fbBindCard).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",fbBindCard).Color=AC.PUR_STROKE
    local fbBindLbl=Instance.new("TextLabel",fbBindCard); fbBindLbl.Size=UDim2.new(0,80,1,0); fbBindLbl.Position=UDim2.new(0,10,0,0); fbBindLbl.BackgroundTransparency=1; fbBindLbl.Text="Keybind:"; fbBindLbl.TextColor3=AC.TXT_MAIN; fbBindLbl.TextSize=12; fbBindLbl.Font=Enum.Font.GothamBold; fbBindLbl.TextXAlignment=Enum.TextXAlignment.Left; fbBindLbl.ZIndex=82
    local fbBindBtn=Instance.new("TextButton",fbBindCard); fbBindBtn.Size=UDim2.new(0,80,0,26); fbBindBtn.Position=UDim2.new(1,-88,0.5,-13); fbBindBtn.BackgroundColor3=AC.BG_PANEL; fbBindBtn.Text="Bind"; fbBindBtn.TextColor3=AC.PUR_GLOW; fbBindBtn.TextSize=12; fbBindBtn.Font=Enum.Font.GothamBold; fbBindBtn.ZIndex=82; Instance.new("UICorner",fbBindBtn).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",fbBindBtn).Color=AC.PUR_STROKE
    fbBindBtn.MouseEnter:Connect(function() AC.TS:Create(fbBindBtn,TweenInfo.new(0.1),{BackgroundColor3=AC.PUR_DARK}):Play() end)
    fbBindBtn.MouseLeave:Connect(function() AC.TS:Create(fbBindBtn,TweenInfo.new(0.1),{BackgroundColor3=AC.BG_PANEL}):Play() end)
    local fbKey=nil; local fbBindListening=false; local fbBindConn=nil
    fbBindBtn.MouseButton1Click:Connect(function()
        if fbBindListening then
            fbBindListening=false; if fbBindConn then fbBindConn:Disconnect(); fbBindConn=nil end
            fbBindBtn.Text=fbKey and "["..fbKey:sub(1,4).."]" or "Bind"
            fbBindBtn.TextColor3=fbKey and AC.TXT_WHITE or AC.PUR_GLOW; return
        end
        fbBindListening=true; fbBindBtn.Text="..."; fbBindBtn.TextColor3=AC.ORANGE_W
        fbBindConn=AC.UIS.InputBegan:Connect(function(inp,gp)
            if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            local ok2,kn=pcall(function() return inp.KeyCode.Name end)
            if not ok2 or not kn or kn=="" or kn=="Unknown" then return end
            if kn=="Escape" then
                fbBindListening=false; if fbBindConn then fbBindConn:Disconnect(); fbBindConn=nil end
                fbBindBtn.Text=fbKey and "["..fbKey:sub(1,4).."]" or "Bind"
                fbBindBtn.TextColor3=fbKey and AC.TXT_WHITE or AC.PUR_GLOW; return
            end
            fbKey=kn; fbBindBtn.Text="["..kn:sub(1,4).."]"; fbBindBtn.TextColor3=AC.TXT_WHITE
            fbBindListening=false; if fbBindConn then fbBindConn:Disconnect(); fbBindConn=nil end
            AC.toast("FaceBang bound to ["..kn.."]",AC.PUR_BRIGHT)
        end)
    end)
    local fbDistLbl=Instance.new("TextLabel",fbPanel); fbDistLbl.Size=UDim2.new(0,140,0,14); fbDistLbl.Position=UDim2.new(0,10,0,108); fbDistLbl.BackgroundTransparency=1; fbDistLbl.Text="Thrust Distance:"; fbDistLbl.TextColor3=AC.TXT_MAIN; fbDistLbl.TextSize=11; fbDistLbl.Font=Enum.Font.GothamBold; fbDistLbl.ZIndex=81
    local fbDistVal=Instance.new("TextLabel",fbPanel); fbDistVal.Size=UDim2.new(0,30,0,14); fbDistVal.Position=UDim2.new(1,-40,0,108); fbDistVal.BackgroundTransparency=1; fbDistVal.Text="3"; fbDistVal.TextColor3=AC.PUR_GLOW; fbDistVal.TextSize=11; fbDistVal.Font=Enum.Font.GothamBold; fbDistVal.ZIndex=81
    local fbDistTrk=Instance.new("Frame",fbPanel); fbDistTrk.Size=UDim2.new(1,-16,0,6); fbDistTrk.Position=UDim2.new(0,8,0,126); fbDistTrk.BackgroundColor3=Color3.fromRGB(30,30,30); fbDistTrk.ZIndex=81; Instance.new("UICorner",fbDistTrk).CornerRadius=UDim.new(1,0)
    local fbDistFil=Instance.new("Frame",fbDistTrk); fbDistFil.Size=UDim2.new(0.18,0,1,0); fbDistFil.BackgroundColor3=AC.PUR_MID; fbDistFil.ZIndex=82; Instance.new("UICorner",fbDistFil).CornerRadius=UDim.new(1,0)
    local fbDistKnob=Instance.new("TextButton",fbDistTrk); fbDistKnob.Size=UDim2.new(0,14,0,14); fbDistKnob.Position=UDim2.new(0.18,-7,0.5,-7); fbDistKnob.BackgroundColor3=AC.PUR_GLOW; fbDistKnob.Text=""; fbDistKnob.ZIndex=83; Instance.new("UICorner",fbDistKnob).CornerRadius=UDim.new(1,0)
    local fbDist=3; local _fbDDC=nil
    local function setFbDist(v) v=math.clamp(math.floor(v+0.5),1,8); fbDist=v; fbDistVal.Text=tostring(v); local r=(v-1)/7; fbDistFil.Size=UDim2.new(r,0,1,0); fbDistKnob.Position=UDim2.new(r,-7,0.5,-7) end
    fbDistKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _fbDDC=AC.RS.RenderStepped:Connect(function() setFbDist(1+(AC.UIS:GetMouseLocation().X-fbDistTrk.AbsolutePosition.X)/fbDistTrk.AbsoluteSize.X*7) end) end end)
    fbDistTrk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then setFbDist(1+(AC.UIS:GetMouseLocation().X-fbDistTrk.AbsolutePosition.X)/fbDistTrk.AbsoluteSize.X*7); if not _fbDDC then _fbDDC=AC.RS.RenderStepped:Connect(function() setFbDist(1+(AC.UIS:GetMouseLocation().X-fbDistTrk.AbsolutePosition.X)/fbDistTrk.AbsoluteSize.X*7) end) end end end)
    AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 and _fbDDC then _fbDDC:Disconnect(); _fbDDC=nil end end)
    setFbDist(3)
    local fbSpdLbl=Instance.new("TextLabel",fbPanel); fbSpdLbl.Size=UDim2.new(0,140,0,14); fbSpdLbl.Position=UDim2.new(0,10,0,148); fbSpdLbl.BackgroundTransparency=1; fbSpdLbl.Text="Thrust Speed:"; fbSpdLbl.TextColor3=AC.TXT_MAIN; fbSpdLbl.TextSize=11; fbSpdLbl.Font=Enum.Font.GothamBold; fbSpdLbl.ZIndex=81
    local fbSpdVal=Instance.new("TextLabel",fbPanel); fbSpdVal.Size=UDim2.new(0,30,0,14); fbSpdVal.Position=UDim2.new(1,-40,0,148); fbSpdVal.BackgroundTransparency=1; fbSpdVal.Text="5"; fbSpdVal.TextColor3=AC.PUR_GLOW; fbSpdVal.TextSize=11; fbSpdVal.Font=Enum.Font.GothamBold; fbSpdVal.ZIndex=81
    local fbSpdTrk=Instance.new("Frame",fbPanel); fbSpdTrk.Size=UDim2.new(1,-16,0,6); fbSpdTrk.Position=UDim2.new(0,8,0,166); fbSpdTrk.BackgroundColor3=Color3.fromRGB(30,30,30); fbSpdTrk.ZIndex=81; Instance.new("UICorner",fbSpdTrk).CornerRadius=UDim.new(1,0)
    local fbSpdFil=Instance.new("Frame",fbSpdTrk); fbSpdFil.Size=UDim2.new(0.33,0,1,0); fbSpdFil.BackgroundColor3=AC.PUR_MID; fbSpdFil.ZIndex=82; Instance.new("UICorner",fbSpdFil).CornerRadius=UDim.new(1,0)
    local fbSpdKnob=Instance.new("TextButton",fbSpdTrk); fbSpdKnob.Size=UDim2.new(0,14,0,14); fbSpdKnob.Position=UDim2.new(0.33,-7,0.5,-7); fbSpdKnob.BackgroundColor3=AC.PUR_GLOW; fbSpdKnob.Text=""; fbSpdKnob.ZIndex=83; Instance.new("UICorner",fbSpdKnob).CornerRadius=UDim.new(1,0)
    local fbSpd=5; local _fbSDC=nil
    local function setFbSpd(v) v=math.clamp(math.floor(v+0.5),1,16); fbSpd=v; fbSpdVal.Text=tostring(v); local r=(v-1)/15; fbSpdFil.Size=UDim2.new(r,0,1,0); fbSpdKnob.Position=UDim2.new(r,-7,0.5,-7) end
    fbSpdKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _fbSDC=AC.RS.RenderStepped:Connect(function() setFbSpd(1+(AC.UIS:GetMouseLocation().X-fbSpdTrk.AbsolutePosition.X)/fbSpdTrk.AbsoluteSize.X*15) end) end end)
    fbSpdTrk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then setFbSpd(1+(AC.UIS:GetMouseLocation().X-fbSpdTrk.AbsolutePosition.X)/fbSpdTrk.AbsoluteSize.X*15); if not _fbSDC then _fbSDC=AC.RS.RenderStepped:Connect(function() setFbSpd(1+(AC.UIS:GetMouseLocation().X-fbSpdTrk.AbsolutePosition.X)/fbSpdTrk.AbsoluteSize.X*15) end) end end end)
    AC.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 and _fbSDC then _fbSDC:Disconnect(); _fbSDC=nil end end)
    setFbSpd(5)
    local fbActiveBg=Instance.new("Frame",fbPanel); fbActiveBg.Size=UDim2.new(1,-16,0,40); fbActiveBg.Position=UDim2.new(0,8,0,186); fbActiveBg.BackgroundColor3=AC.BG_CARD; fbActiveBg.ZIndex=81; Instance.new("UICorner",fbActiveBg).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",fbActiveBg).Color=AC.PUR_STROKE
    local fbActiveLbl=Instance.new("TextLabel",fbActiveBg); fbActiveLbl.Size=UDim2.new(1,-60,1,0); fbActiveLbl.Position=UDim2.new(0,12,0,0); fbActiveLbl.BackgroundTransparency=1; fbActiveLbl.Text="FaceBang Active"; fbActiveLbl.TextColor3=AC.TXT_MAIN; fbActiveLbl.TextSize=13; fbActiveLbl.Font=Enum.Font.GothamBold; fbActiveLbl.TextXAlignment=Enum.TextXAlignment.Left; fbActiveLbl.ZIndex=82
    local fbTrk=Instance.new("TextButton",fbActiveBg); fbTrk.Size=UDim2.new(0,44,0,24); fbTrk.Position=UDim2.new(1,-54,0.5,-12); fbTrk.BackgroundColor3=Color3.fromRGB(40,40,40); fbTrk.Text=""; fbTrk.ZIndex=82; Instance.new("UICorner",fbTrk).CornerRadius=UDim.new(1,0)
    local fbKnob=Instance.new("Frame",fbTrk); fbKnob.Size=UDim2.new(0,18,0,18); fbKnob.Position=UDim2.new(0,3,0.5,-9); fbKnob.BackgroundColor3=AC.TXT_DIM; Instance.new("UICorner",fbKnob).CornerRadius=UDim.new(1,0)
    local fbWarn=Instance.new("TextLabel",fbPanel); fbWarn.Size=UDim2.new(1,-16,0,14); fbWarn.Position=UDim2.new(0,8,0,234); fbWarn.BackgroundTransparency=1; fbWarn.Text="! Disable noclip for best results"; fbWarn.TextColor3=AC.ORANGE_W; fbWarn.TextSize=9; fbWarn.Font=Enum.Font.GothamBold; fbWarn.TextXAlignment=Enum.TextXAlignment.Left; fbWarn.ZIndex=81
    local fbActive=false; local fbConn=nil; local fbLastTarget=nil
    local function fbGetNearestPlayer()
        local myChar=AC.player.Character; if not myChar then return nil end
        local myRoot=myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return nil end
        local best=nil; local bestDist=math.huge
        for _,p in ipairs(AC.Players:GetPlayers()) do
            if p~=AC.player and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart"); if r then
                    local d=(r.Position-myRoot.Position).Magnitude
                    if d<bestDist then bestDist=d; best=p end
                end
            end
        end
        return best
    end
    local function fbStop()
        if fbConn then fbConn:Disconnect(); fbConn=nil end
        fbActive=false; fbLastTarget=nil
        local myChar=AC.player.Character
        if myChar then
            local mr=myChar:FindFirstChild("HumanoidRootPart")
            local hum=myChar:FindFirstChildOfClass("Humanoid")
            if mr then
                pcall(function() mr.AssemblyLinearVelocity=Vector3.zero end)
                pcall(function() mr.AssemblyAngularVelocity=Vector3.zero end)
                local p=mr.CFrame.Position
                mr.CFrame=CFrame.new(p)*CFrame.Angles(0,select(2,mr.CFrame:ToEulerAnglesYXZ()),0)
            end
            if hum then
                hum.PlatformStand=false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            end
            task.delay(0.1, function()
                pcall(function()
                    if myChar and myChar.Parent then
                        local h=myChar:FindFirstChildOfClass("Humanoid")
                        if h then h.PlatformStand=false; pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end) end
                        local r=myChar:FindFirstChild("HumanoidRootPart")
                        if r then pcall(function() r.AssemblyLinearVelocity=Vector3.zero end) end
                    end
                end)
            end)
        end
        AC.TS:Create(fbTrk,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play()
        AC.TS:Create(fbKnob,TweenInfo.new(0.2),{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=AC.TXT_DIM}):Play()
        fbStatus.Text="Target: none  |  Status: OFF"
        AC.toast("FaceBang OFF",AC.ORANGE_W)
    end
    local function fbStart()
        local tgt=fbGetNearestPlayer(); if not tgt or not tgt.Character then AC.toast("No nearby player!",AC.RED_ERR); return end
        local tHead=tgt.Character:FindFirstChild("Head"); if not tHead then AC.toast("Target has no head",AC.RED_ERR); return end
        local myChar=AC.player.Character; if not myChar then return end
        local myRoot=myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
        local myHum=myChar:FindFirstChildOfClass("Humanoid"); if myHum then myHum.PlatformStand=true end
        fbActive=true; fbLastTarget=tgt
        AC.TS:Create(fbTrk,TweenInfo.new(0.2),{BackgroundColor3=AC.PUR_MID}):Play()
        AC.TS:Create(fbKnob,TweenInfo.new(0.2),{Position=UDim2.new(1,-21,0.5,-9),BackgroundColor3=AC.PUR_GLOW}):Play()
        fbStatus.Text="Target: "..tgt.Name.."  |  Status: ON"
        AC.toast("FaceBang ON  ->  "..tgt.Name,AC.PUR_BRIGHT)
        local t=0
        fbConn=AC.RS.Heartbeat:Connect(function(dt)
            if not fbActive then return end
            if not fbLastTarget or not fbLastTarget.Character then fbStop(); return end
            local th=fbLastTarget.Character:FindFirstChild("Head")
            local mr=myChar:FindFirstChild("HumanoidRootPart")
            if not th or not mr then fbStop(); return end
            t=t+dt*fbSpd
            local osc=math.abs(math.sin(t))
            local pull=math.clamp(osc*fbDist, 0, fbDist)
            local headPos=th.CFrame.Position
            local faceFwd=th.CFrame.LookVector
            local targetPos=headPos + faceFwd*(1.8 + pull)
            mr.CFrame=CFrame.new(targetPos, headPos)
        end)
    end
    fbTrk.MouseButton1Click:Connect(function()
        pcall(function() AC.clickSnd:Play() end)
        if fbActive then fbStop() else fbStart() end
    end)
    AC.UIS.InputBegan:Connect(function(inp,gp)
        pcall(function()
            if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            if not fbKey then return end
            local kn=inp.KeyCode.Name
            if not kn or kn=="" or kn=="Unknown" then return end
            if kn==fbKey then if fbActive then fbStop() else fbStart() end end
        end)
    end)
    fbBtn.MouseButton1Click:Connect(function()
        fbPanel.Visible=not fbPanel.Visible
        if fbPanel.Visible then
            local vp=AC.camera.ViewportSize
            local pos=fbPanel.Position
            fbPanel.Position=UDim2.new(0,math.clamp(pos.X.Offset,0,vp.X-FB_W),0,math.clamp(pos.Y.Offset,0,vp.Y-FB_H))
        end
    end)
end

-- QUICK BAR
do
    local qBar=Instance.new("Frame",AC.screenGui); qBar.Size=UDim2.new(0,186,0,44); qBar.BackgroundColor3=Color3.fromRGB(8,8,8); qBar.BackgroundTransparency=0.15; qBar.ZIndex=400; qBar.ClipsDescendants=false; Instance.new("UICorner",qBar).CornerRadius=UDim.new(1,0); Instance.new("UIStroke",qBar).Color=AC.PUR_STROKE
    task.defer(function()
        local vp=AC.camera.ViewportSize
        qBar.Position=UDim2.new(0,10,0,vp.Y-130)
    end)
    local qDrag=false; local qDS=nil; local qSPx=0; local qSPy=0
    qBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            qDrag=true; qDS=i.Position; qSPx=qBar.Position.X.Offset; qSPy=qBar.Position.Y.Offset
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then qDrag=false end end)
        end
    end)
    AC.UIS.InputChanged:Connect(function(i)
        if qDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-qDS; local vp=AC.camera.ViewportSize
            qBar.Position=UDim2.new(0,math.clamp(qSPx+d.X,0,vp.X-186),0,math.clamp(qSPy+d.Y,0,vp.Y-44))
        end
    end)
    local qL=Instance.new("TextLabel",qBar); qL.Size=UDim2.new(0,28,1,0); qL.Position=UDim2.new(0,8,0,0); qL.BackgroundTransparency=1; qL.Text="AC"; qL.TextColor3=AC.PUR_GLOW; qL.TextSize=11; qL.Font=Enum.Font.GothamBold; qL.ZIndex=401
    local function makeChip(label,xOff,onColor,onToggle)
        local chip=Instance.new("TextButton",qBar); chip.Size=UDim2.new(0,44,0,30); chip.Position=UDim2.new(0,xOff,0.5,-15); chip.BackgroundColor3=Color3.fromRGB(22,22,22); chip.Text=label; chip.TextColor3=AC.TXT_DIM; chip.TextSize=10; chip.Font=Enum.Font.GothamBold; chip.ZIndex=401; Instance.new("UICorner",chip).CornerRadius=UDim.new(1,0); local cs=Instance.new("UIStroke",chip); cs.Color=AC.PUR_STROKE; cs.Thickness=1; cs.Transparency=0.5
        local active=false
        chip.MouseButton1Click:Connect(function() active=not active; if active then AC.TS:Create(chip,TweenInfo.new(0.15),{BackgroundColor3=onColor,TextColor3=AC.TXT_WHITE}):Play(); cs.Transparency=1 else AC.TS:Create(chip,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(22,22,22),TextColor3=AC.TXT_DIM}):Play(); cs.Transparency=0.5 end; pcall(function() AC.clickSnd:Play() end); onToggle(active) end)
    end
    makeChip("SPD",42,Color3.fromRGB(30,160,60),function(v) local h=AC.player.Character and AC.player.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=v and 50 or 16 end end)
    makeChip("FLY",92,Color3.fromRGB(20,100,220),function(v)
        AC.flyActive=v; local char=AC.player.Character; if not char then return end; local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end; local hum=char:FindFirstChildOfClass("Humanoid")
        if v then if hum then hum.PlatformStand=true end; local att=Instance.new("Attachment",root); AC._flyAtt=att; AC.flyBV=Instance.new("LinearVelocity"); AC.flyBV.Attachment0=att; AC.flyBV.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector; AC.flyBV.MaxForce=1e5; AC.flyBV.RelativeTo=Enum.ActuatorRelativeTo.World; AC.flyBV.VectorVelocity=Vector3.zero; AC.flyBV.Parent=root; AC.flyBG=Instance.new("AlignOrientation"); AC.flyBG.Attachment0=att; AC.flyBG.Mode=Enum.OrientationAlignmentMode.OneAttachment; AC.flyBG.MaxTorque=1e5; AC.flyBG.MaxAngularVelocity=math.huge; AC.flyBG.Responsiveness=50; AC.flyBG.Parent=root; AC.flyConn=AC.RS.RenderStepped:Connect(function() if not AC.flyActive then return end; local cf=AC.camera.CFrame; local dir=Vector3.zero; if AC.UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end; if AC.UIS:IsKeyDown(Enum.KeyCode.E) then dir=dir+Vector3.new(0,1,0) end; if AC.UIS:IsKeyDown(Enum.KeyCode.Q) then dir=dir-Vector3.new(0,1,0) end; if dir.Magnitude>0 then dir=dir.Unit end; AC.flyBV.VectorVelocity=dir*60; AC.flyBG.CFrame=cf end)
        else if AC.flyConn then AC.flyConn:Disconnect(); AC.flyConn=nil end; if AC.flyBV then AC.flyBV:Destroy(); AC.flyBV=nil end; if AC.flyBG then AC.flyBG:Destroy(); AC.flyBG=nil end; if AC._flyAtt then AC._flyAtt:Destroy(); AC._flyAtt=nil end; if hum then hum.PlatformStand=false end end
    end)
    makeChip("NC",140,Color3.fromRGB(200,100,10),function(v)
        if v then AC.noclipConn=AC.RS.Stepped:Connect(function() local char=AC.player.Character; if not char then return end; for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
        else if AC.noclipConn then AC.noclipConn:Disconnect(); AC.noclipConn=nil end; if AC.player.Character then for _,p in ipairs(AC.player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end
    end)
end

-- OPEN ANIMATION
do
    AC.switchTab("Home")
    AC.wrapper.Visible=false
    AC.wrapper.Size=UDim2.new(0,0,0,0)
    AC.wrapper.Position=UDim2.new(0.5,0,0.5,0)
    task.delay(0.08,function()
        AC.wrapper.Visible=true
        pcall(function() AC.openSound:Play() end)
        AC.TS:Create(AC.wrapper,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size=UDim2.new(0,AC.UI_W,0,AC.UI_H),
            Position=UDim2.new(0.5,-AC.UI_W/2,0.5,-AC.UI_H/2)
        }):Play()
        task.delay(0.5,function() AC._uiOpen=true end)
    end)
    task.delay(1.4,function() AC.toast("AC AudioCrafter v4.79 loaded!  G = toggle") end)
    print("AC AudioCrafter V4.79  by MelodyCrafter")
    print("  G = toggle UI | Emotes tab: Reanimation + Open Emote Menu")
end

-- AUTO RE-EXECUTE ON SERVER CHANGE
pcall(function()
    _G.__AC_AUTORUN_VER = AC_VER
    local TS=game:GetService("TeleportService")
    pcall(function()
        AC.player.OnTeleport:Connect(function(teleportState)
            if teleportState==Enum.TeleportState.InProgress then
                pcall(function()
                    if writefile and isfolder then
                        writefile("AC/__autorejoin.json", game:GetService("HttpService"):JSONEncode({
                            placeId=game.PlaceId, ver=AC_VER, time=os.time()
                        }))
                    end
                end)
                AC.toast("Teleporting — AC will reload on join",AC.PUR_BRIGHT)
            end
        end)
    end)
    pcall(function()
        if not isfile then return end
        if not isfile("AC/__autorejoin.json") then return end
        local ok,data=pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("AC/__autorejoin.json"))
        end)
        if ok and data and type(data)=="table" then
            local age = os.time() - (data.time or 0)
            if age < 30 then
                task.delay(2, function()
                    AC.toast("Auto-reloaded after server change!",AC.GREEN_OK)
                end)
            end
        end
        pcall(function() writefile("AC/__autorejoin.json","{}") end)
    end)
end)
