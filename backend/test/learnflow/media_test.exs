defmodule Learnflow.MediaTest do
  use ExUnit.Case, async: true

  alias Learnflow.Media

  test "web_ready? only accepts browser-friendly MP4" do
    h264 = %{video_codec: "h264", audio_codec: "aac", pix_fmt: "yuv420p", width: 720, height: 1280}

    assert Media.web_ready?(h264, "videos/1/source.mp4")
    refute Media.web_ready?(h264, "videos/1/source.mov")
    refute Media.web_ready?(%{h264 | video_codec: "hevc"}, "videos/1/source.mp4")
    refute Media.web_ready?(%{h264 | width: 3840, height: 2160}, "videos/1/source.mp4")
  end

  @tag :ffmpeg
  test "converts an HEVC MOV into H.264 MP4 and extracts a thumbnail" do
    if Media.available?() do
      dir = Path.join(System.tmp_dir!(), "media-test-#{System.unique_integer([:positive])}")
      File.mkdir_p!(dir)
      source = Path.join(dir, "clip.mov")

      {_, 0} =
        System.cmd("ffmpeg", ~w(-y -loglevel error -f lavfi -i testsrc=size=1080x1920:rate=30 -f lavfi -i sine -t 3
                                -c:v libx265 -tag:v hvc1 -c:a aac -shortest) ++ [source])

      assert {:ok, info} = Media.probe(source)
      assert info.video_codec == "hevc"
      assert_in_delta info.duration, 3.0, 0.2
      refute Media.web_ready?(info, "videos/1/source.mov")

      output = Path.join(dir, "video.mp4")
      assert :ok = Media.transcode(source, output)
      assert {:ok, converted} = Media.probe(output)
      assert converted.video_codec == "h264"
      assert converted.audio_codec == "aac"
      assert {converted.width, converted.height} == {720, 1280}
      assert Media.web_ready?(converted, "videos/1/video.mp4")

      thumb = Path.join(dir, "thumb.jpg")
      assert :ok = Media.thumbnail(source, thumb, info.duration)
      assert File.stat!(thumb).size > 0

      File.rm_rf(dir)
    end
  end
end
