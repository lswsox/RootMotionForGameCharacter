--������ : �̻��
global RMC_DataCA
-- ���� attribID ��ȣ�� �÷������� �����ϴ� �߿��� ��ȣ�ε�, ���� �ʹݿ� �߿��� �Ǽ��� �߾��� ������ ������.
-- (���� ��Ͽ�) �ڵ� ���� ���ϰ� ����ٰ� attributes �ܺο��� global ������ RMC_ID = #(0x7b72aada, 0x1462108b) �̷� ������ ����� Ŀ���� ��Ʈ����Ʈ���� ������ ����ߴ��� ������ ���� �ε��� ������ global ������ �ν��� �� ��� �� �����Ͱ� ��� missing DLL ���� ������ üũ�ϰ� �����Ϸ��� ��.
-- attribID ���� ����: https://help.autodesk.com/view/MAXDEV/2022/ENU/?guid=GUID-9F96FB7D-EB51-41FA-976D-C39DEED69CE4
-- ��� ���, ���� �������� attribID�� �ڵ� ������ ���� ���ڷ� ����ؾ���.
RMC_DataCA= attributes RMC_Data attribID:#(0x7b72aada, 0x1462108b) (
	parameters main rollout:RMCRollout (
		--������Ʈ ������ #node Ÿ������ �ϸ� ��Ʈ ���� circular dependency ���谡 �Ǿ expression ��Ʈ�ѷ��� ���� ������ �Ұ���.
		--�׷��� #node Ÿ�� ��ſ� #integer Ÿ������ �����ϰ� inode.handle ������� ������Ʈ�� ����Ŵ.
		--���� #node Ÿ���� ��Ͽ����� ���ܵ�.
		--PelvisObj type:#node subAnim:false	--subAnim�� true�� �ϸ� ���õ� ������Ʈ�� �ִϸ��̼��� Ŀ���� ��Ʈ����Ʈ������ �ٷ� �� �ְ� �ȴ�. false�� �ϸ� Ŀ�� ������ Ʈ������ ������ �ʰ� ��������.
		PelvisObjHandle type:#integer subAnim:false
		RootObjHandle type:#integer subAnim:false

		-- Ŀ�� ������ Ʈ������ �빮�ڷ� ǥ�õǱ� ���� �Ķ���� ������ �빮�ڷ� �����ϰ� ��.
		ManualX type:#float ui:spnManualX default:0
		ManualY type:#float ui:spnManualY default:0
		ManualZ type:#float ui:spnManualZ default:0
		TrackX type:#float ui:sliderTrackX default:0
		TrackX_Offset type:#float ui:spnTrackX_Offset default:0
		TrackY type:#float ui:sliderTrackY default:0
		TrackY_Offset type:#float ui:spnTrackY_Offset default:0
		TrackZ type:#float ui:sliderTrackZ default:0
		TrackZ_Offset type:#float ui:spnTrackZ_Offset default:0
		ManualYaw type:#float ui:spnManualYaw default:0
		TrackYaw type:#float ui:sliderTrackYaw default:0
		TrackYaw_Offset type:#float ui:spnTrackYaw_Offset default:90
	)

	-- �Ѿƿ��� ui ������ �Ķ���͸��� �����ϰ� ���� ���ƾ� �̺�Ʈ���� ������ ����� �� ������ �߻����� ����.
	rollout RMCRollout ("Root Motion Controller 0.93") (
		local animStateBackup	-- OnButtonDown, OnButtonUp �Լ����� Auto Key ���¸� ������ ��Ȱ���ϱ� �� ���� ���¸� ����ϱ� ���� ���� ����

		pickbutton pickAnimPelvisObj "Pick Animated Pelvis" width:140 tooltip:"�ִϸ��̼ǵ� pelvis�� �����մϴ�. �����е��� ��� Bip001�� �������ּ���.\nSelect the animated pelvis. For the Bipad, select Bip001."
		label labelPelvisObj "Pelvis: " align:#left offset:[0, -6]
		pickbutton pickRootObj "Pick Root" width:140 tooltip:"��Ʈ�� ����� ������Ʈ�� �������ּ���.\nSelect an object to use as the root."
		label labelRootObj "Root: " align:#left offset:[0, -6]
		button btnLinkController "Link Controller" width:140 tooltip:"Root�� ��Ʈ�ѷ��� �����ϰ� Pelvis�� �����մϴ�.\nApply the controller to Root and connect it with Pelvis."
		
		group "Position Control" (
			spinner spnManualX "ManualX" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100
			spinner spnManualY "ManualY" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100
			spinner spnManualZ "ManualZ" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100
			label labelTrackX "TrackX" align:#left width:50 offset:[0, 10] across:2
			slider sliderTrackX "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left offset:[-20, -4]
			spinner spnTrackX_Offset "TrackX_Offset" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:136
			label labelTrackY "TrackY" align:#left width:50 offset:[0, 10] across:2
			slider sliderTrackY "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left offset:[-20, -4]
			spinner spnTrackY_Offset "TrackY_Offset" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:136
			label labelTrackZ "TrackZ" align:#left width:50 offset:[0, 10] across:2
			slider sliderTrackZ "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left offset:[-20, -4]
			spinner spnTrackZ_Offset "TrackZ_Offset" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:136
			button btnGetPelvisPosZ "Get Pelvis PosZ" align:#center width:140 tooltip:"�������κ��� ����� ���� ���� �ڵ����� ������ TrackZ_Offset�� �����մϴ�.\nAutomatically gets the height value of the pelvis from the ground and applies it to TrackZ_Offset."
		)
		
		group "Rotation Control" (
			spinner spnManualYaw "ManualYaw" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100
			label labelTrackYaw "TrackYaw" align:#left width:50 offset:[0, 10] across:2
			slider sliderTrackYaw "" type:#float range:[0.0, 1.0, 0.0] width:90 align:#left offset:[-10, -4]
			spinner spnTrackYaw_Offset "TrackYaw_Offset" type:#float range:[-99999.0, 99999.0, 90.0] align:#left width:118 tooltip:"Default = 90"
		)

		label labelAbout "cafe.naver.com/pinksox/9011"
		
		function Initialize = (
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if (pelvisObj != undefined) do (
				labelPelvisObj.text = "Pelvis: " + pelvisObj.name
			)
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if (rootObj != undefined) do (
				labelRootObj.text = "Root: " + rootObj.name
			)
			-- �Ķ���Ϳ� ��Ʈ�ѷ��� �����Ǿ����� ������ ��Ʈ�ѷ� ����
			if (ManualX.controller == undefined) do (ManualX.controller = bezier_float ())
			if (ManualY.controller == undefined) do (ManualY.controller = bezier_float ())
			if (ManualZ.controller == undefined) do (ManualZ.controller = bezier_float ())
			if (TrackX.controller == undefined) do (TrackX.controller = bezier_float ())
			if (TrackX_Offset.controller == undefined) do (TrackX_Offset.controller = bezier_float ())
			if (TrackY.controller == undefined) do (TrackY.controller = bezier_float ())
			if (TrackY_Offset.controller == undefined) do (TrackY_Offset.controller = bezier_float ())
			if (TrackZ.controller == undefined) do (TrackZ.controller = bezier_float ())
			if (TrackZ_Offset.controller == undefined) do (TrackZ_Offset.controller = bezier_float ())
			if (ManualYaw.controller == undefined) do (ManualYaw.controller = bezier_float ())
			if (TrackYaw.controller == undefined) do (TrackYaw.controller = bezier_float ())
			if (TrackYaw_Offset.controller == undefined) do (TrackYaw_Offset.controller = bezier_float ())
		)

		on pickAnimPelvisObj picked obj do (
			if obj == undefined do return()
			PelvisObjHandle = obj.inode.handle
			labelPelvisObj.text = "Pelvis: " + obj.name
		)

		on pickRootObj picked obj do (
			if obj == undefined do return()
			RootObjHandle = obj.inode.handle
			labelRootObj.text = "Root: " + obj.name
		)
		
		on btnLinkController pressed do (
			-- ��� ������Ʈ�� �ϳ��� �������� ������ �׳� ����
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if pelvisObj == undefined do return()
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj == undefined do return()
			local myRMC_Data = selection[1].baseObject.RMC_Data	-- Root Motion Controller �Ѿƿ� ������

			-- ������ ��Ʈ�ѷ� ����
			rootObj.pos.controller = Position_XYZ ()
			-- �� �κ��� ��Ʈ�ѷ��� ���� ����ȭ �Ͽ� �������� �ܼ�ȭ�Ϸ��� ������ �������� AddScalarTarget�� �۵����� ����.
			rootObj.pos.controller.X_Position.controller = Float_Expression ()
			rootObj.pos.controller.Y_Position.controller = Float_Expression ()
			rootObj.pos.controller.Z_Position.controller = Float_Expression ()
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "ManualX" myRMC_Data.ManualX.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "ManualY" myRMC_Data.ManualY.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "ManualZ" myRMC_Data.ManualZ.controller
			rootObj.pos.controller.X_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.Y_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.Z_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "TrackX" myRMC_Data.TrackX.controller
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "TrackX_Offset" myRMC_Data.TrackX_Offset.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "TrackY" myRMC_Data.TrackY.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "TrackY_Offset" myRMC_Data.TrackY_Offset.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ" myRMC_Data.TrackZ.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ_Offset" myRMC_Data.TrackZ_Offset.controller
			rootObj.pos.controller.X_Position.controller.SetExpression "(TrackX_Offset + PelvisPos.x)*TrackX + ManualX*(1-TrackX)"
			rootObj.pos.controller.Y_Position.controller.SetExpression "(TrackY_Offset + PelvisPos.y)*TrackY + ManualY*(1-TrackY)"
			rootObj.pos.controller.Z_Position.controller.SetExpression "(TrackZ_Offset + PelvisPos.z)*TrackZ + ManualZ*(1-TrackZ)"
			
			-- �����̼� ��Ʈ�ѷ� ����
			rootObj.rotation.controller
			rootObj.rotation.controller = Euler_XYZ ()
			rootObj.rotation.controller.X_Rotation.controller = Float_Expression ()	-- �� ��� �����̼ǵ� ������ 0���� �ʱ�ȭ
			rootObj.rotation.controller.X_Rotation.controller.SetExpression "0"
			rootObj.rotation.controller.Y_Rotation.controller = Float_Expression ()	-- �� ��� �����̼ǵ� ������ 0���� �ʱ�ȭ
			rootObj.rotation.controller.Y_Rotation.controller.SetExpression "0"
			rootObj.rotation.controller.Z_Rotation.controller = float_script ()			-- Z �����̼��� Bip001�� ȸ���� ���������� ��ũ��Ʈ ��Ʈ�ѷ� ����
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "ManualYaw" myRMC_Data.ManualYaw.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw" myRMC_Data.TrackYaw.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw_Offset" myRMC_Data.TrackYaw_Offset.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddNode "PelvisObj" pelvisObj
			rootObj.rotation.controller.Z_Rotation.controller.SetExpression "local pelvisYaw = degToRad (PelvisObj.transform.rotation as EulerAngles).z
local track = (pelvisYaw + degToRad (TrackYaw_Offset)) * TrackYaw
local manual = degToRad(ManualYaw) * (1-TrackYaw)
return (track + manual)"
		)

		on btnGetPelvisPosZ pressed do (
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if pelvisObj == undefined do return()
			TrackZ_Offset = -pelvisObj.transform.pos.z	-- ���̳ʽ� ó��
		)

		-- ������Ʈ�� ���õ� ������ �Ѿƿ��� ���µǰ� �̺�Ʈ�� ����ȴ�.
		on RMCRollout open do (
			Initialize()
		)

		-- �÷��� ���� �����̴��� ���ǳ� ��ȭ�� ���� �� �ִϸ��̼� Ű�� �������� �ʵ��� ���� �Լ�
		function OnButtonDown = (
			animStateBackup = animButtonState
			if isAnimPlaying() do (
				animButtonState = false		-- �����̴��� ���ǳ� ��ȭ �߿��� ������ �ִϸ��̼� Off
			)
		)

		function OnButtonUp = (
			animButtonState = animStateBackup
		)

		on spnManualX buttondown do (OnButtonDown())
		on spnManualX buttonup do (OnButtonUp())
		on spnManualY buttondown do (OnButtonDown())
		on spnManualY buttonup do (OnButtonUp())
		on spnManualZ buttondown do (OnButtonDown())
		on spnManualZ buttonup do (OnButtonUp())
		on sliderTrackX buttondown do (OnButtonDown())
		on sliderTrackX buttonup do (OnButtonUp())
		on spnTrackX_Offset buttondown do (OnButtonDown())
		on spnTrackX_Offset buttonup do (OnButtonUp())
		on sliderTrackY buttondown do (OnButtonDown())
		on sliderTrackY buttonup do (OnButtonUp())
		on spnTrackY_Offset buttondown do (OnButtonDown())
		on spnTrackY_Offset buttonup do (OnButtonUp())
		on sliderTrackZ buttondown do (OnButtonDown())
		on sliderTrackZ buttonup do (OnButtonUp())
		on spnTrackZ_Offset buttondown do (OnButtonDown())
		on spnTrackZ_Offset buttonup do (OnButtonUp())
		on spnManualYaw buttondown do (OnButtonDown())
		on spnManualYaw buttonup do (OnButtonUp())
		on sliderTrackYaw buttondown do (OnButtonDown())
		on sliderTrackYaw buttonup do (OnButtonUp())
		on spnTrackYaw_Offset buttondown do (OnButtonDown())
		on spnTrackYaw_Offset buttonup do (OnButtonUp())
   )
)

global RootMotionTools		-- �Ѿƿ����� �۷ι� ������ �ν��ϱ� ���� �ʱ⿡ �� �� ���
try (destroydialog RootMotionTools) catch()		-- Ȥ�� �����ִ� â�� ������ ���� ����

rollout RootMotionTools ("Root Motion Tools 0.93") width:200
(
	local STRING_PICK_CONTROLLER = "Pick Controller"
	
	pickbutton uiPickController STRING_PICK_CONTROLLER width:166 tooltip:"��Ʈ�ѷ� ������Ʈ�� ����\n(��Ŭ��: ��ϵ� ������Ʈ�� �����մϴ�)\nPick the controller object\n(Right-click: Select the registered object)"
	button uiAddRMC "Add RMC" width:80 tooltip:"Add Root Motion Controller"across:2
	button uiRemoveRMC "Remove RMC" width:80 tooltip:"Remove Root Motion Controller"
	group "Other Tools" (
		button uiRemoveAnyCustomAttribute "Remove Any Custom Attribute" width:166 tooltip:"������ ����̴� �������ּ���.\n������ ��� ���� Ŀ���� ��Ʈ����Ʈ �ϳ��� ����.\nThis is a dangerous feature, so be careful.\nRemove one custom attribute of any type."
	)
	button uiBtnHelp "About"

	/*
	button uiTest "Test"
	on uiTest pressed do (
	)
	*/
	
	-- Ŀ���� ��Ʈ����Ʈ�� attribID�� ������ ����. attribID�� ���� ���ϸ� ������ false���� attribID �� ���ڸ� ���ϴ� �Լ�.
	function CompareAttribID idA idB = (
		if (idA[1] == idB[1] AND idA[2] == idB[2]) then (return true) else (return false)
	)

	-- ������Ʈ�� ��Ʈ ��� ��Ʈ�ѷ� ��Ʈ����Ʈ �ε����� ����. ������ 0 ����
	function GetRootMotionControllerAttrIndex obj = (
		local attrCount = custAttributes.count obj
		for i = 1 to attrCount do (
			local tID = (custAttributes.getDef obj i).attribID
			if (CompareAttribID tID #(0x7b72aada, 0x1462108b)) do (return i)
		)
		return 0		
	)

	-- ���� ������ ��Ʈ ��� ��Ʈ�ѷ� ���� �߰ߵǴ� ���� ����
	function FindRootMotionController = (
		for obj in objects do (
			if (GetRootMotionControllerAttrIndex obj) != 0 do (return obj)
		)
		return undefined	-- ������ undefined ����
	)

	-- �ʱ�ȭ �Լ�
	function Initialize = (
		-- �� ��ü�� ������ ��Ʈ�ѷ� ������Ʈ�� �ִ��� �˻�. ã�� ������ RMC_DataCA Ŀ���� ��Ʈ����Ʈ�� �ִ���.
		local controllerObj = FindRootMotionController()
		if (controllerObj == undefined) then (	--������ ��Ʈ�ѷ� �ȹ�ư�� ���.
			uiPickController.object = undefined
			uiPickController.text = STRING_PICK_CONTROLLER	
		)
		else (	--������ �ȹ�ư �ʱ�ȭ
			uiPickController.object = controllerObj
			uiPickController.text = controllerObj.name
		)
	)
	
	on uiPickController picked obj do (
		if obj == undefined then (
			uiPickController.text = STRING_PICK_CONTROLLER
		)
		else (
			uiPickController.text = obj.name
			select obj
		)
	)

	-- �ȹ�ư ��Ŭ���ϸ� �ش� ������Ʈ ����
	on uiPickController rightclick do (
		local controllerObj = uiPickController.object
		if (controllerObj != undefined AND	-- ������� �װ�
			(not (isdeleted controllerObj))	-- �������� �ʾҴٸ�
		) do (select controllerObj)			-- ������Ʈ ����
	)
	
	on uiAddRMC pressed do (
		local controllerObj = uiPickController.object
		if (controllerObj == undefined OR (isdeleted controllerObj)) do (
			messagebox "��Ʈ�ѷ� ������Ʈ�� �������ּ���"
			return()
		)

		select controllerObj
		-- ������ RMC_DataCA�� �ִ��� �����ؼ� ������ �߰�
		local attrIndex = GetRootMotionControllerAttrIndex controllerObj
		if attrIndex != 0 then (
			messagebox "�̹� Root Motion Controller�� �����մϴ�.\nThe Root Motion Controller already exists."
		)
		else (
			custAttributes.add controllerObj RMC_DataCA
		)
	)

	on uiRemoveRMC pressed do (
		local controllerObj = uiPickController.object
		if (controllerObj == undefined OR (isdeleted controllerObj)) do (
			messagebox "��Ʈ�ѷ� ������Ʈ�� �������ּ���"
			return()
		)

		select controllerObj
		local attrIndex = GetRootMotionControllerAttrIndex controllerObj
		if attrIndex != 0 do (
			custAttributes.delete controllerObj attrIndex	-- ������ Ŀ���� ��Ʈ����Ʈ�� �ִϸ��̼� Ű�� �����ȴ�.
		)
	)

	on uiRemoveAnyCustomAttribute pressed do (
		local controllerObj = uiPickController.object
		if (controllerObj == undefined OR (isdeleted controllerObj)) do (
			messagebox "��Ʈ�ѷ� ������Ʈ�� �������ּ���"
			return()
		)

		select controllerObj
		custAttributes.delete controllerObj 1	-- ������ Ŀ���� ��Ʈ����Ʈ�� �ִϸ��̼� Ű�� �����ȴ�.
	)
	
	on RootMotionTools open do (
        callbacks.addScript #filePostOpen "RootMotionTools.Initialize ()" id:#RootMotionToolsOpen
		callbacks.addScript #systemPostNew "RootMotionTools.Initialize ()" id:#RootMotionToolsNew
		callbacks.addScript #systemPostReset "RootMotionTools.Initialize ()" id:#RootMotionToolsReset
		--callbacks.addScript #sceneUndo "RootMotionTools.UnDoCallBack ()" id:#RootMotionToolsUnDo

		Initialize()
	)
	
	on RootMotionTools close do (
		callbacks.removeScripts id:#RootMotionToolsOpen
		callbacks.removeScripts id:#RootMotionToolsNew
		callbacks.removeScripts id:#RootMotionToolsReset
		--callbacks.removeScripts id:#RootMotionToolsUnDo
	)

	on uiBtnHelp pressed do (
		shellLaunch "https://cafe.naver.com/pinksox/9011" ""
	)
)
createDialog RootMotionTools style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) lockWidth:true