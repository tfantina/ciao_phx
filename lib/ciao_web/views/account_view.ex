defmodule CiaoWeb.AccountView do
  alias Phoenix.LiveView.UploadEntry

  import Phoenix.LiveView.Helpers, only: [live_img_preview: 2]
  use CiaoWeb, :view

  def get_profile_pic(%UploadEntry{} = image, opts \\ []), do: live_img_preview(image, opts)
  def get_profile_pic(_, _opts), do: "No profile pic yet"
end
