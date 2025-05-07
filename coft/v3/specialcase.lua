local AssetService = game:GetService("AssetService")

local module = {}

module['MeshPart'] = {
	process={'MeshId', 'CollisionFidelity', 'RenderFidelity', 'FluidFidelity', 'TextureID'};
	callback=function(obj: MeshPart, props: {[string]: any})
		local MeshId: string = props.MeshId
		if not MeshId then
			warn('no MeshId for', obj:GetFullName())
			return
		end
		
		local CollisionFidelity: Enum.CollisionFidelity = props.CollisionFidelity or Enum.CollisionFidelity.Default
		local RenderFidelity: Enum.RenderFidelity = props.RenderFidelity or Enum.RenderFidelity.Automatic
		local FluidFidelity: Enum.FluidFidelity = props.FluidFidelity or Enum.FluidFidelity.Automatic
		local TextureID: string = props.TextureID or ''
		
		local mp = AssetService:CreateMeshPartAsync(Content.fromUri(MeshId), {
			CollisionFidelity=CollisionFidelity;
			RenderFidelity=RenderFidelity;
			FluidFidelity=FluidFidelity;
		})
		mp.TextureID = TextureID
		
		obj:ApplyMesh(mp)
	end;
} :: SpecialCase

return module
