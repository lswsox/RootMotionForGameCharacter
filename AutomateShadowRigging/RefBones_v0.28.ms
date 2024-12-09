--만든이 : 이상원
--사용 환경 : Max 2008 이상 (nodeLocalBoundingBox 가 2008 이상)

global RefBones		-- 롤아웃명을 글로벌 변수로 인식하기 위해 초기에 한 번 사용

try (destroydialog RefBones) catch()		-- 혹시 열려있는 창이 있으면 강제 종료

rollout RefBones "Reference Bones Tool v0.28" width:200
(
	local IDKEYWORD = "RefBone"		-- Ref Bone 임을 알아보는 유저디파인 정보용 키워드 디파인
	local IDKEYWORDHANDLE = "RefBoneHandle"		-- Ref Bone 임을 알아보는 유저디파인 정보용 키워드 디파인
	local IDKEYWORDTARGETHANDLE = "RefBoneTargetHandle"		-- Ref 본 의 타겟에 Ref 본의 핸들 번호를 기록
	local NAMEPREFIX = "Ref_"
	
	button uiBtnProcess "Process" width:70 across:2
	button uiBtnSelect "Select" width:70
	spinner uiSpnBoneWidth "BoneScale%" offset:[30, 0] tooltip:"생성되는 본의 크기, RefBones를 선택 후 조절해주세요." range:[1, 500, 100] type:#integer align:#right width:110 across:2
	colorPicker uiColorWireColor color:yellow offset:[30, -2] toolTip:"RefBones를 선택 후 색을 변경해주세요."

	checkbox uiChkOptPos "Position" checked:true across:3
	checkbox uiChkOptRot "Rotation" checked:true
	checkbox uiChkOptScale "Scale" checked:true
	
	checkbox uiChkOptInheritScale "Inherit Scale" checked:false align:#left toolTip:"Default: Off\r특별한 경우가 아니면 Inherit Scale은 끄기를 권장합니다." across:2
	checkbox uiChkOptAutoParent "Auto Parent" checked:true align:#left toolTip:"Default: On\r생성된 Ref본들의 계층구조가 자동으로 연결됩니다."
	
	/*
	Set Scalable Biped 버튼은 척추와 쇄골의 위치를 보정해주는 서브애님까지 추가하는 작업이 필요해서 만들다 말고 홀드 --> 서브애님 위치 보정을 해보려 ?는데, 단순 스케일에서 어긋나는 포지션이 규칙이 없다. (스케일을 키를 걸어놓고 보면 확실함)
	button uiBtnSetScalableBiped "Set Scalable Biped" tooltip:"Scale이 가능한 바이패드로 변경하고 Scale을 조정하는 헬퍼를 추가합니다."
	*/
	
	button uiBtnHelp "About"
	
	function GetAlignBB obj = (		-- 월드 좌표상에서 자유롭게 회전되어있는 오브젝트의 바운딩 박스 포지션을 월드 중점으로 위치와 회전을 리셋하여 point 값 두 개를 리턴한다. 주로 길이를 재기 위한 용도
		local bb = nodeGetBoundingBox obj obj.transform		-- 로컬 바운딩 박스 포지션 값 두 개가 배열로 bb에 저장됨 bb[1], bb[2]
		
		if ((classof obj.baseobject) == Point) do
		(	-- 포인트헬퍼는 점으로만 존재해서 바운딩박스를 강제로 넣어줘야한다.
			bb[1].x -= obj.baseobject.size * 0.5
			bb[1].y -= obj.baseobject.size * 0.5
			bb[2].x += obj.baseobject.size * 0.5
			bb[2].y += obj.baseobject.size * 0.5
		)
		return bb
	)
	
	function GetWidthX obj = (		-- 선택된 오브젝트의 로컬 바운딩 박스 기준으로 x축 방향의 두께를 알아낸다. (길이가 아닌 두께 --> 본의 두께 값에 사용하기 위함)
		local bb = GetAlignBB obj		-- 월드 중점으로 회전과 위치가 리셋된 바운딩 박스 생성
		return (((abs (bb[2].y - bb[1].y)) + (abs (bb[2].z - bb[1].z))) / 2.0)		-- z축 두께와 y축 두께의 평균값을 구한다.
	)
	
	function CheckWorkingBone obj = (		-- 어떤 작업을 할지 검사. "IGNORE", "CREATE", "MODIFY" 이렇게 세 가지 string을 리턴한다.
		if (getUserProp obj "RefBone") == true do (return "MODIFY")
		
		local tFlag = false		-- 임시 플래그 생성
		
		-------------------- 검사 시작
		if (classof obj.baseobject == Biped_Object) do (tFlag = true)		-- 바이패드인 경우, 모디파이어가 적용된 바이패드나 본에는 baseobject 처리해줘야함
		if (obj.BoneEnable == true) do (tFlag = true)		-- 본인 경우
		if (classof obj.baseobject == Point) do (tFlag = true)
		if (classof obj.baseobject == Dummy) do (tFlag = true)
		
		if ((getUserProp obj IDKEYWORD) == true) do (tFlag = false)		-- 최종적으로 RefBone 이면 무조건 false 처리
		-------------------- 검사 끝
		
		if tFlag == true then (return "CREATE") else (return "IGNORE")
	)

	-- children이 Array로 바로 변환이 안돼서 만든 함수. 배열을 리턴
	function ChildrenToArray childrenArray = (
		local returnArray = #()
		for o in childrenArray do (
			append returnArray o
		)
		return returnArray
	)
	
	function FindLookAtPos obj = (		-- 바이패드의 뿌리 목처럼 쇄골 방향으로도 자식이 여럿 있는 본은 머리를 바라보면서 RefBone 이 생성되어야 한다. 이런 경우 똑똑하게 바라볼 본을 찾아주는 함수. 바라볼 위치를 리턴한다.
	-- 작동 방식은, 부모 본 위치에서 자식본 위치의 거리를 모두 알아내서, 부모본으로부터 x축으로 이동시켰더니 거리가 오히려 멀어지면 바라보는 본이 아니라는 방식으로 검출
	-- 검사중인 obj 가 일반 본일 경우 .length 값을 활용한다.
	-- 자식이 없는 바이패드 오브젝트나 일반 오브젝트의 BoneOn 인 경우에는 바운딩 박스 정보를 길이로 활용한다.
		
		local tMatrix = obj.transform		-- 스케일이 리셋된 기준으로 tLength 계산을 해야함
		tMatrix.scale = [1, 1, 1]
		tMatrix.rotation = obj.transform.rotation
		tMatrix.position = obj.transform.position
		
		local tLength = 1.0		-- 계산할 길이 변수 셋팅. 디폴트는 spinner 값
		
		if obj.children.count == 0 then (		-- 자식이 하나도 없는 경우 본의 length 값을 이용하거나 로컬 바운딩 박스 중심으로부터 양의 x축 길이를 이용한다.
			tLength = case (classof obj.baseobject) of
			(
			BoneGeometry: obj.baseobject.length * obj.transform.scale.x
			Biped_Object: (biped.getTransform obj #scale).x
			default: (GetAlignBB obj)[2].x
			)
			/*
			if ((classof obj.baseobject) == BoneGeometry) then (
				tLength = obj.baseobject.length * obj.transform.scale.x
			)
			else (
				tLength = (GetAlignBB obj)[2].x
			)
			*/
		)
		else		-- 자식이 하나 이상인 경우
		(
			local targetNode
			local beforeDist = -1.0
            local childrenObjs = #() -- 자식들이 여럿일 때 바이패드가 하나라도 있으면 바이패드만 대상으로 자식을 다시 선별하기 위한 배열
            
            for o in obj.children do (
                if (classof o.baseobject) == Biped_Object do (
                    append childrenObjs o -- 바이패드로 판명되면 배열에 추가
                )
            )
            
            if childrenObjs.count == 0 do (
                -- 바이패드가 하나도 발견되지 않으면 childrenObjs에 원래 자식들을 다시 적용
                childrenObjs = ChildrenToArray obj.children
            )
			for o in childrenObjs do (
				-- obj는 처리하려는 본, o는 obj의 자식들 중 하나
				vDist = distance obj.transform.pos o.transform.pos		-- vDist는 처리하려는 오브젝트로부터 자식 오브젝트의 거리를 측정
				if vDist > 0.001 do (		-- 같은 위치에 있는 본은 처리 대상에서 제외한다. 제외 결과 자식이 하나도 없을 수 있는데 이때는 tLength 는 기본값인 1.0이 된다.
					xPos = ((transMatrix [vDist, 0, 0]) * tMatrix).pos		-- 자식오브젝트 거리만큼 기준 오브젝트의 x축으로 이동한 위치
					endDist = distance xPos o.transform.pos		-- 이동한 위치로부터 자식 오브젝트까지의 거리 (이 거리가 짧을 수록 실제 목표 자식임. x축에 정렬되어있을 수록 이 거리가 짧다. x축에 벗어나면 이 거리가 커진다.)
					
					if beforeDist == -1.0 OR endDist <= beforeDist do (		-- 현재 o의 endDist 가 이전보다 더 짧으면 o를 타겟 노드로 지정 후 beforeDist 업데이트
						targetNode = o
						beforeDist = endDist
						tLength = (cos ((90 - acos ((endDist * 0.5) / vDist)) * 2)) * vDist		-- 타겟이 x축 중심에서 어긋나있을 경우에는 삼각함수로 계산해야함
					)
				)
			)
		)
		local halfWith = (GetWidthX obj) * 0.5
		tLength = amax tLength halfWith	-- 길이가 매우 짧은 본이 생기지 않도록 함. Bip001과 Pelvis 등 동일한 위치에 있는 경우 tLength는 두께의 50%를 대신 사용. 100% 크기로 하기에는 중첩된 위치의 본들이 너무 크게 생성되는 것이 부담됨.
		return ((transMatrix [tLength, 0, 0]) * tMatrix).pos		-- obj로부터 tLength 만큼 이동한 트랜스폼의 pos 리턴
	)
	
	function CreateBone pStart pEnd vUp vSize = (		-- 시작점, 끝점, 업벡터, 두께 입력받고 본 생성. 나머지 모든 본 지오메트리 변수들은 디폴트로 강제 셋팅
		local tBone = BoneSys.createBone pStart pEnd vUp
		tBone.width = vSize
		tBone.height = vSize
		tBone.taper = 90.0
		-- tBone.length 이것은 자동 결정됨
		tBone.sidefins = false
		tBone.sidefinssize = vSize * 0.5
		tBone.sidefinsstarttaper 
		tBone.sidefinsendtaper 
		tBone.frontfin = false
		tBone.frontfinsize = vSize * 0.5
		tBone.frontfinstarttaper 
		tBone.frontfinendtaper 
		tBone.backfin = false
		tBone.backfinsize = vSize * 0.5
		tBone.backfinstarttaper = 10.0
		tBone.backfinendtaper = 10.0
		tBone.genmap = false
		
		tBone.boneScaleType=#none
		tBone.boneAutoAlign=false
		
		return tBone
	)
	
	function SetRefBoneAttr targetObj newObj = (		-- Ref Bone 속성과 컬러를 적용한다
		newObj.WireColor = uiColorWireColor.color
		setUserProp newObj IDKEYWORD "true"
		setUserProp newObj IDKEYWORDHANDLE targetObj.inode.handle
		setUserProp targetObj IDKEYWORDTARGETHANDLE newObj.inode.handle
		newObj.name = NAMEPREFIX + targetObj.name
	)
	
	function SetRefController targetObj newObj = (		-- 타겟 오브젝트를 따라하도록 스크립트 컨트롤러로 변경. 변경 당시 본의 상대적인 transform 유지는 보류.
		-- 일단 컨트롤러 리셋
		newObj.pos.controller = Position_XYZ ()
		newObj.rotation.controller = Euler_XYZ ()
		newObj.scale.controller = bezier_scale ()

		newObj.scale = targetObj.transform.scale
		newObj.rotation = targetObj.transform.rotation
		newObj.pos = targetObj.transform.pos
		
		if (uiChkOptPos.state == true) do (
			newObj.pos.controller = Position_Constraint ()
			newObj.pos.controller.appendTarget targetObj 50.0
		)

		if (uiChkOptRot.state == true) do (
			newObj.rotation.controller = Orientation_Constraint ()
			newObj.rotation.controller.appendTarget targetObj 50.0
		)

		if (uiChkOptScale.state == true) do (
			newObj.scale.controller = scale_script ()
			newObj.scale.controller.AddNode "TG" targetObj
			newObj.scale.controller.SetExpression "tScale = try (TG.transform.scale * TG.inode.stretchTM.scale) catch ([1, 1, 1])
if abs (tScale.x - 1.0) < 0.00001 do (tScale.x = 1.0)
if abs (tScale.y - 1.0) < 0.00001 do (tScale.y = 1.0)
if abs (tScale.z - 1.0) < 0.00001 do (tScale.z = 1.0)
tScale"
		)

		-- Scale 상속
		if ( uiChkOptInheritScale.state == false ) then (
			setInheritanceFlags newObj #{1, 2, 3, 4, 5, 6}		-- scale 상속 관련 문제를 막기 위해 inherit 를 꺼줌
		)
		else (
			setInheritanceFlags newObj #{1, 2, 3, 4, 5, 6, 7, 8, 9}		-- scale 을 강제로 상속하려면 켜줌
		)
	)

	-- 레프본이 참조하는 원본 (바이패드 등)을 리턴한다.
	function GetRefOrigin ref = (
		local handle = getUserProp ref IDKEYWORDHANDLE
		return (maxOps.getNodeByHandle handle)
	)

	-- 원본이 참조하는 Ref본을 리턴한다. 원본에 Ref본 기록이 없거나 찾을 수 없으면 undefined 리턴.
	function GetRef origin = (
		local refBone
		try (refBone = maxOps.getNodeByHandle (getUserProp origin IDKEYWORDTARGETHANDLE))
		catch (refBone = undefined)
		return refBone
	)
	
	function GetExistRef obj = (		-- 현재 처리하려고 하는 오브젝트에 이미 Ref Bone 이 생성되어있는지를 조사. Ref Bone 툴로 생성된 본에는 무조건 IDKEYWORDHANDLE = "RefBoneHandle" 의 유저 프로퍼티로 원본 본의 핸들 번호가 있기때문에 이를 조사함)
		if obj == undefined do return undefined		-- 부모의 Ref Bone 을 찾는 과정에서 undefined 가 obj 로 입력될 수 있어서 방어코드
		
		local rNode
		rNode = GetRef obj -- 일단 현재 오브젝트에 Ref본 기록이 있는지 찾아본다.
		if (rNode != undefined) do (return rNode) -- 기록이 있으면 그 오브젝트를 리턴

		-- 기록이 없으면 전체 오브젝트 안에서 다 찾아본다.
		for o in objects do (
			if (obj.inode.handle == getUserProp o IDKEYWORDHANDLE) do (rNode = o)
		)
		return rNode		-- Ref Bone 을 리턴한다. 못찾으면 undefined 리턴
	)
	
	function AutoParent targetObj newObj = (		-- 새로 생성된 Ref Bone 의 부모를 자동 지정하도록 하는 함수
		if targetObj.parent == undefined do return ()		-- 타겟 오브젝트의 부모가 없으면 그냥 리턴해야함

		local tObj = GetExistRef targetObj.parent		-- 타겟 오브젝트 부모의 Ref Bone 을 찾는다.
		if tObj != undefined do (newObj.parent = tObj)		-- 타겟 부모의 Ref Bone을 찾았으면 새로 생긴 Ref Bone의 부모로 링크
	)
	
	-- obj 의 모든 자식들을 배열로 리턴. 배열 순서는 계층구조 순서대로
	function GetAllChildren obj = (
		if ( obj == undefined ) do return undefined
		
		local tAllChildren = #()
		if ( obj.children.count != 0 ) do (
			for o in obj.children do (
				append tAllChildren o
				if ( o.children.count != 0 ) do (
					tAllChildren = tAllChildren +  (GetAllChildren o)		-- recursive
				)
			)
		)
		
		return tAllChildren
	)
	
	-- 선택이 바이패드라면, 소속된 모든 바이패드를 리턴.
	function GetAllBiped obj = (
		if ( obj == undefined ) do return undefined
		if ( classof obj.baseobject != Biped_Object ) do return undefined
		
		local bipedRoot = obj.controller.rootNode
		
		local allChildren = GetAllChildren bipedRoot
		
		local allBiped = #()
		for o in allChildren do
		(
			if classof o.baseobject == Biped_Object do
			(
				append allBiped o
			)
		)
		return allBiped
	)

	on uiBtnProcess pressed do (
		if selection.count == 0 do return ()		-- 선택된 오브젝트가 없으면 그냥 리턴
		local panelModeBackup = getCommandPanelTaskMode()	-- 커맨드 패널이 애니메이션 모드이면 매우 느리게 작동하므로 잠시 Modify 모드로 전환하기 위해 현재 상태를 기록
		setCommandPanelTaskMode #modify						-- 속도 이슈가 없는 modify 패널로 임시 변경 (처리 후 다시 백업된 패널로 복귀 예정)

		undo on (		-- Undo 가 가능하도록
			local tTarget = #()		-- 부모 링크 작업을 위해서는 모든 Ref Bone 이 생겨난 뒤에 for 문을 한 번 더 돌려야하므로 작업 대상을 기억시키는 배열이 필요함
			local tNew = #()		-- 부모 링크 작업을 위해서는 모든 Ref Bone 이 생겨난 뒤에 for 문을 한 번 더 돌려야하므로 작업 대상을 기억시키는 배열이 필요함
			for o in selection do (
				local checkStr = CheckWorkingBone o
				case of (
					(checkStr == "CREATE"):(
						-- 바이패드를 선택한 채 Process를 눌렀음. Ref본을 생성하거나 기존 Ref본을 수정함.
						local foundRefBone = GetExistRef o
						
						local tBone
						if foundRefBone != undefined then (
							tBone = foundRefBone	-- 이미 생성된 Ref 본이 발견됨
						)
						else (
							-- 새로운 Ref 본 생성
							tBone = CreateBone o.transform.pos (FindLookAtPos o) o.dir ((GetWidthX o) * (uiSpnBoneWidth.value * 0.01))
						)
						-- 이 단계를 거치면 어쨋든 tBone은 RefBone
						
						SetRefBoneAttr o tBone		-- RefBone 속성 지정
						SetRefController o tBone		-- 컨트롤러 변경
						if ((classof o.baseobject) != Point AND (classof o.baseobject) != Dummy) do
						(
							o.boxMode = on
						)
						append tTarget o
						append tNew tBone
					)
					(checkStr == "MODIFY"):(
						-- Ref본을 선택한 채 Process를 눌렀음. Ref본을 수정하기만 함'
						-- 이 경우 o가 Ref본
						local tOrigin = GetRefOrigin o

						SetRefBoneAttr tOrigin o		-- RefBone 속성 지정
						SetRefController tOrigin o		-- 컨트롤러 변경

						if ((classof tOrigin.baseobject) != Point AND (classof tOrigin.baseobject) != Dummy) do (
							tOrigin.boxMode = on
						)
						append tTarget tOrigin
						append tNew o
					)
					default:()
				)
			) -- for end

			-- Auto Parent
			if tTarget.count != 0 AND uiChkOptAutoParent.state do (		-- CheckWorkingBone 체크에 의해 tTarget 개수가 0일 가능성이 있음.
				for o = 1 to tTarget.count do (AutoParent tTarget[o] tNew[o])
			)
			
			select tNew	-- 작업을 마친 후 생성된 RefBone들을 선택함.
		)
		setCommandPanelTaskMode panelModeBackup	-- 처리가 끝난 후 원래 패널로 되돌림.
	)
	
	on uiBtnSelect pressed do (
		local tSel = #()
		for o in objects do (
			if ((getUserProp o IDKEYWORD) == true) do (append tSel o)
		)
		select tSel
	)
	
	on uiSpnBoneWidth changed var do (
		if selection.count == 0 do return ()
		local tObj = #()
		for o in selection do (
			if (getUserProp o IDKEYWORD) == true do (append tObj o)		-- 선택 오브젝트들 안에서 Ref Bone 만 골라낸다
		)
		if tObj.count == 0 do return ()
		
		for o in tObj do (
			tNode = maxOps.getNodeByHandle (getUserProp o IDKEYWORDHANDLE)		-- 핸들 번호로 타겟 본을 역으로 알아낸다. 못찾으면 tNode 는 undefined
			tScale = 1.0 / ((tNode.transform.scale.y + tNode.transform.scale.z) * 0.5)
			if tNode != undefined do (
				tValue = (GetWidthX tNode) * (uiSpnBoneWidth.value * 0.01 * tScale)
				o.width = tValue
				o.height = tValue
			)
		)			
	)
	
	on uiColorWireColor changed var do (
		for o in selection do (
			if ((getUserProp o IDKEYWORD) == true) do (o.wirecolor = var)
		)
	)
	
	-- 스케일시 1번 척추와 쇄골의 위치가 엉뚱한 곳에 있게된다. 이것을 보정해주는 Position 서브애님 컨트롤러를 추가해야함.
	on uiBtnSetScalableBiped pressed do
	(
		if selection[1] == undefined do return()
		if (classof selection[1].baseobject != Biped_Object) do return()
		
	
		local allBiped = GetAllBiped selection[1]
		local rootBiped = selection[1].controller.rootNode
		local pelvis = biped.getNode selection[1] #Pelvis link:1
		
		local newPoint = Point isSelected:off Box:on Centermarker:off axistripod:off cross:off size:((GetWidthX pelvis) * 2.2) wirecolor:green
		newPoint.transform = rootBiped.transform
		newPoint.parent = rootBiped
		
		-- 혹시 모를 오류를 방지하기 위해 figure모드는 꺼준다.
		rootBiped.controller.figureMode = false
		
		--paramWire.connect $.transform.controller[#Scale] $'Bip001 L Forearm'.transform.controller.Biped_SubAnim.controller.BipScaleList.controller[#Bezier_Scale] "Scale"

		for o in allBiped do
		(
			if ( classof o.controller == BipSlave_Control) do
			(
				o.controller.Biped_SubAnim.controller.BipScaleList.Available.controller = bezier_scale()
				o.controller.Biped_SubAnim.controller.BipScaleList.active = o.controller.Biped_SubAnim.controller.BipScaleList.count
				
				paramWire.connect newPoint.transform.controller[#Scale] o.transform.controller.Biped_SubAnim.controller.BipScaleList.controller[o.controller.Biped_SubAnim.controller.BipScaleList.count] "Scale"
			)
		)
		select newPoint
	)

	on uiBtnHelp pressed do (
		shellLaunch "http://cafe.naver.com/pinksox/5035" ""
	)
	
	on RefBones open do (

	)
	
	on RefBones close do (

	)
)
createDialog RefBones style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) lockWidth:true