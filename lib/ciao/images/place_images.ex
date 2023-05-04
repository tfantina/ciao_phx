defmodule Ciao.Images.PlaceImages do 
    @moduledoc """
    Uses ImageCreators macro to upload place profile pic and create varaints
    """
    
    import Ciao.EctoSupport 
    @variants ["200x200"]
    use Ciao.Images.ImageCreators, domain: "place", otp_app: :ciao, variants: @variants

end 