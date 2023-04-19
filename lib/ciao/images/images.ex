defmodule Ciao.Images do
  @moduledoc """
  Module for creating and managing images.
  Images are used throughout the site and in varying contexts however they all
  live under the Images umbrella.  If this ever becomes unmanagable these functions
  should be extracted into behaviours and composed in seperate modules.
  """
  alias Ciao.Images.ImageRecord
  use Ciao.Query, for: ImageRecord
end
