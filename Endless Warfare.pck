GDPC                                                                            *   <   res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex 8      U      -��`�0��x�5�[   res://HUD.gd.remap  @V             �1����D� i�d�bn0   res://HUD.gdc   @            ��[�@= n$��A(�P   res://HUD.tscn  `      �        "���Cl�2����w�`   res://HUD/HUD.gd.remap  `V      "       �`OٺI����'�   res://HUD/HUD.gdc          <       ���7���~}b�մV(   res://HUD/Rolling Selection/Icon.tscn   @      �      s�	��`�,�#�E�C<8   res://HUD/Rolling Selection/Rolling Selection.gd.remap  �V      B       0��>(Su���}�7�ؖ4   res://HUD/Rolling Selection/Rolling Selection.gdc   �      �       �������,�z���4   res://HUD/Rolling Selection/Rolling Selection.tscn  �      ~      &�kM��+аE��mb4   res://HUD/Rolling Selection/TextureButton.gd.remap  �V      >       ��Ai8�R�"�C[͠�0   res://HUD/Rolling Selection/TextureButton.gdc          Z      ;SC��){qޡ0sw   res://Info.gd.remap  W             ch�0�m�L~|�e�   res://Info.gdc  �      �      �3�%�H��t�jع�   res://Info.tscn `      �       ����}��0V5����/   res://LogRecorder.gd.remap  @W      &       Q�A}����R�?P   res://LogRecorder.gdc           �      {i�$��'�5̻�6�   res://Main.gd.remap pW             �(@Er�#��K�F�[   res://Main.gdc  �$      }      hL�W�..遼�o   res://Main.tscn  (      �      A!_���?:	��&qv   res://Test/Test.gd.remap�W      $       yq���-m̀q�W�p   res://Test/Test.gdc �+      C      nZ�966�� eq~XK�g   res://default_env.tres   .      �       um�`�N��<*ỳ�8$   res://game_world/Database.gd.remap  �W      .       �M
/QNc�  �    res://game_world/Database.gdc   �.      ?      �q���v���b��    res://game_world/Database.tscn  1      �       p�e҆z��$�z~�    res://game_world/Map.gd.remap   �W      )       r+��^�<��(ˌc   res://game_world/Map.gdc�1      A       ��m�ǒ?�VmS��ٜ�$   res://game_world/Navigation.gd.remap X      0       �I_�L���%>e��8    res://game_world/Navigation.gdc 2      �      �^��1!�?�C<{�0    res://game_world/World.gd.remap PX      +       W�_0����=�U�ȼV   res://game_world/World.gdc  �4      J       =~�I䒕A%a�6{p�   res://game_world/World.tscn @5      �      r���]1��V�0��   res://icon.png  0Y      �      G1?��z�c��vN��   res://icon.png.import   �E      �      "�Պ����$��㹌(   res://pck_loading/PacksManager.gd.remap �X      3       5�Pc�V��6��d>$   res://pck_loading/PacksManager.gdc  0H      l      K���	�\���_�M�T    res://pck_loading/pck.gd.remap  �X      *       �P�N޳���r?��&   res://pck_loading/pck.gdc   �P      �      �Z �T���Q�9{�k   res://project.binary f            �7^��M��L23�0   res://script_templates/script_template.gd.remap �X      ;       �M=�����ׂ��y,   res://script_templates/script_template.gdc  0U            E{p.���rI�MOvGDSC             #      ���Ӷ���   ����¶��   �����϶�                                                 	   	   
   
                                                                !      3YYYYYYYYYYY0�  PQV�  -�  Y0�  PQV�  -YYYYY`          [gd_scene load_steps=2 format=2]

[ext_resource path="res://HUD/HUD.gd" type="Script" id=1]

[node name="HUD" type="CanvasLayer"]
script = ExtResource( 1 )
    GDSC                   ����������Ķ             3Y`    [gd_scene load_steps=5 format=2]

[ext_resource path="res://icon.png" type="Texture" id=1]
[ext_resource path="res://HUD/Rolling Selection/TextureButton.gd" type="Script" id=2]

[sub_resource type="Animation" id=1]
resource_name = "Decrease"
tracks/0/type = "value"
tracks/0/path = NodePath(".:rect_scale")
tracks/0/interp = 1
tracks/0/loop_wrap = true
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/keys = {
"times": PoolRealArray( 0, 0.2 ),
"transitions": PoolRealArray( 1, 1 ),
"update": 0,
"values": [ Vector2( 2, 2 ), Vector2( 1, 1 ) ]
}

[sub_resource type="Animation" id=2]
resource_name = "increase"
tracks/0/type = "value"
tracks/0/path = NodePath(".:rect_scale")
tracks/0/interp = 1
tracks/0/loop_wrap = true
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/keys = {
"times": PoolRealArray( 0, 0.2 ),
"transitions": PoolRealArray( 1, 1 ),
"update": 0,
"values": [ Vector2( 1, 1 ), Vector2( 2, 2 ) ]
}

[node name="TextureButton" type="TextureButton"]
margin_left = -32.0
margin_top = -32.0
margin_right = 32.0
margin_bottom = 32.0
rect_scale = Vector2( 2, 2 )
rect_pivot_offset = Vector2( 32, 32 )
texture_normal = ExtResource( 1 )
texture_pressed = ExtResource( 1 )
texture_hover = ExtResource( 1 )
texture_disabled = ExtResource( 1 )
texture_focused = ExtResource( 1 )
script = ExtResource( 2 )
__meta__ = {
"_edit_use_anchors_": false
}

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
anims/Decrease = SubResource( 1 )
anims/increase = SubResource( 2 )

[node name="Label" type="Label" parent="."]
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
margin_left = -20.0
margin_top = -14.0
margin_right = 20.0
text = "John"

[connection signal="mouse_entered" from="." to="." method="_on_TextureButton_mouse_entered"]
[connection signal="mouse_exited" from="." to="." method="_on_TextureButton_mouse_exited"]
  GDSC            �      ������ڶ   �����¶�   ���ض���   ����Ŷ��   �����϶�   ߶��   ���Ӷ���   �������Ӷ���   ������¶   ����Ķ��   ���Ӷ���   �����Ҷ�   ����Ӷ��   ��������Ҷ��   ���������������Ҷ���   ��������������Ҷ   ���������Ӷ�   
         res://HUD/Icon.tscn       _mouse_entered        on_mouse_entered      _mouse_exited         on_mouse_exited                                      	                           	      
          )      2      =      H      R      Y      e      j      k      r      t      u      |      �      �      �      3YY;�  YY;�  ?P�  QYY;�  LMYY0�  PQV�  �  )�  �K  P�  QV�  ;�  �  T�  PQ�  �  T�  P�  RR�  Q�  �  T�  P�  RR�  Q�  �  T�	  �  T�
  PQ�  �  T�  P�  Q�  �  T�  �  Z�  �  �  �  P�  QYY0�  P�	  QV�  -YY0�  P�	  QV�  )�  �K  P�  T�
  PQQV�  �  L�  MT�  �  P�  R�  QYY`         [gd_scene load_steps=2 format=2]

[ext_resource path="res://HUD/Rolling Selection/Rolling Selection.gd" type="Script" id=1]

[node name="Roll" type="Control"]
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
script = ExtResource( 1 )
__meta__ = {
"_edit_use_anchors_": false
}

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
  GDSC            v      ������������ض��   �������������Ҷ�   ������������Ҷ��   ����Ķ��   ����Ӷ��   ���¶���    ������������������������������Ҷ   ��������������Ķ   ���϶���   ����������ڶ   �������Ŷ���   ����׶��   ������������ض��    �����������������������������Ҷ�   ���������������Ŷ���          �         increase      _mouse_entered        Decrease      _mouse_exited     {�G�z�?                         	      
                     	      
         #      +      2      3      :      M      N      O      U      ]      d      e      l      t      3YYB�  YB�  YY8;�  Y8;�  Y;�  �  YYY0�  PQV�  W�  T�  P�  Q�  �	  P�  R�  QYY0�
  P�  QV�  �  �  P�  P�  Q�  RP�  Q�  QYYY0�  PQV�  W�  T�  P�  Q�  �	  P�  R�  QYY0�  P�  QV�  �  �  �  ZY`      GDSC      	      2      ���Ӷ���   ���ٶ���   �������¶���   �������Ŷ���      version       0.2.1      	   cell_size               echo_recordings             record_navigation_details                enable_test_set                                                     	      
                %      *      .      0      3YY;�  N�  V�  YOYY;�  N�  �  V�  YOYY;�  N�  �  V�  R�  �  V�  R�  �  V�  YOY`           [gd_scene load_steps=2 format=2]

[ext_resource path="res://Info.gd" type="Script" id=1]

[node name="Info" type="Node"]
script = ExtResource( 1 )
             GDSC             �      ���Ӷ���   �����������Ҷ���   ��ն   �����Ҷ�   ������Ӷ   ����ڶ��   ������¶   �嶶   �������Ӷ���   �����Ҷ�   ���ٶ���   �������Ŷ���   ��������������Ŷ   �����������Ķ���   ���Ӷ���   ���¶���   ����������ڶ   ���������Ҷ�   ¶��   ���Ķ���   �����Ӷ�   �����Ҷ�   ߶��   ���Ӷ���   �����޶�             time      text      level         log_recorded            0         [         :               ]                                                       	      
          )      .      2      4      5      <      D      R      S      X      Y      _      b      c      d      k      �      �      �      �      �       3YYB�  YY;�  LMYYYY0�  P�  R�  QV�  ;�  N�  �  V�  T�  PQR�  �  V�  R�  �  V�  �  O�  �  �  T�	  P�  Q�  &�
  T�  T�  V�  �?  P�  P�  T�  Q�  T�  Q�  �  �  P�  QYY0�  PQV�  .�  YYY0�  P�  QV�  ;�  L�>  P�  T�  QR�>  P�  T�  QR�>  P�  T�  QM�  )�  �  T�  PQV�  &�  L�  MT�  PQ�  V�  �  L�  M�  �  L�  M�  .P�  �  LM�  �  L�  M�  �  L�	  M�
  QY`               GDSC            y      ���ӄ�   ���Ŷ���   �����϶�   ����������Ķ   �����Ҷ�   �����������Ķ���   �������ݶ���   ����   �������Ŷ���   ���Ӷ���   ߶��   ������������������϶   ���Ӷ���   ���Ӷ���   �������׶���   ����Ӷ��   �������Ӷ���   ��������Ҷ��      Starting loading mods.        mods       mod(s) loaded successfully.          	   Warning!       $    is not compatible with this version                                                    	      
   "      6      7      A      K      U      Y      Z      ]      l      s      t      u      v      w      3YY;�  YYY0�  PQV�  �  �  T�  PQ�  �  &�  T�  P�  Q�  V�  �  T�  P�>  P�  T�  PQT�	  PQQ�  Q�  �  )�
  �  T�  PQV�  &�
  T�  PQ�  V�  �  T�  P�  �
  T�  �  �  Q�  �  (V�  ;�  �
  T�  PQT�  T�  PQ�  T�  P�  QYYYYY`   [gd_scene load_steps=8 format=2]

[ext_resource path="res://Test/Test.gd" type="Script" id=1]
[ext_resource path="res://Main.gd" type="Script" id=2]
[ext_resource path="res://HUD.tscn" type="PackedScene" id=3]
[ext_resource path="res://game_world/World.tscn" type="PackedScene" id=4]
[ext_resource path="res://pck_loading/PacksManager.gd" type="Script" id=5]
[ext_resource path="res://LogRecorder.gd" type="Script" id=6]
[ext_resource path="res://Info.tscn" type="PackedScene" id=7]

[node name="Main" type="Node2D"]
script = ExtResource( 2 )

[node name="World" parent="." instance=ExtResource( 4 )]

[node name="HUD" parent="." instance=ExtResource( 3 )]

[node name="PCKLoader" type="Node" parent="."]
script = ExtResource( 5 )

[node name="LogRecorder" type="Node" parent="."]
script = ExtResource( 6 )

[node name="Test" type="Node" parent="."]
script = ExtResource( 1 )

[node name="Info" parent="." instance=ExtResource( 7 )]
           GDSC            J      ���Ӷ���   �����϶�   ���ٶ���   �������Ŷ���   ��������������¶   ���������������ض���   ����������޶   ���׶���   �������Ӷ���   ����   ��������Ӷ��   ����������Ķ   �����Ҷ�   ��������Ӷ��                   text      Database tested        successfully                      	                  %      &      /   	   0   
   1      :      H      3YY0�  PQV�  &�  T�  T�  V�  �  �  T�  P�  PRQR�  PR�  QQ�  �  ;�  �  T�	  PQ�  �  �  �  T�
  P�  R�  Q�  �  T�  P�  T�  P�  Q�  QY`             [gd_resource type="Environment" load_steps=2 format=2]

[sub_resource type="ProceduralSky" id=1]

[resource]
background_mode = 2
background_sky = SubResource( 1 )
             GDSC             Z      �������Ӷ���   ���ӄ�   ���׶���   ��������Ӷ��   ��϶   ����Ӷ��   ����   ��������Ӷ��   �����������Ӷ���   ��Ŷ   �����������������ⶶ   ����Ӷ��   �������׶���                                                    	   !   
   "      )      /      0      7      A      D      K      N      O      U      X      2Y3�  YY;�  NOYYY0�  P�  R�  QV�  �  L�  M�  �  .�  �  Y0�  P�  QV�  .�  L�  MYY0�  P�  QV�  &�  T�	  P�  QV�  .�
  �  �  T�  P�  Q�  .�  �  Y0�  PQV�  .�  Y` [gd_scene load_steps=2 format=2]

[ext_resource path="res://game_world/Database.gd" type="Script" id=1]

[node name="Database" type="Node2D"]
script = ExtResource( 1 )
        GDSC                   ���ӄ�                   3YY`               GDSC            k      ���������؄򶶶�   ����������޶   ����¶��   ��Ҷ   �������Ӷ���   ���ٶ���   �������Ŷ���   ������������������������Ŷ��   ����������Ķ   �����Ҷ�   ��������������޶   �������¶���   ��������Ӷ��            Calculated optimized path from         to       Calculated path from                                                     "   	   &   
   ,      :      =      C      Q      R      ^      i      3YYYYY0�  P�  V�  R�  V�  R�  V�  QV�  �  &�  T�  T�  V�  &�  V�  �  T�	  P�  �  �>  P�  Q�  �>  P�  QQ�  (V�  �  T�	  P�  �  �>  P�  Q�  �>  P�  QQ�  �  .�
  P�  �  T�  T�  R�  �  �  T�  T�  R�  QY`             GDSC                   ���ӄ�                         3YYY`      [gd_scene load_steps=4 format=2]

[ext_resource path="res://game_world/World.gd" type="Script" id=1]
[ext_resource path="res://game_world/Navigation.gd" type="Script" id=2]
[ext_resource path="res://game_world/Map.gd" type="Script" id=4]

[node name="World" type="Node2D"]
script = ExtResource( 1 )

[node name="Map" type="Node2D" parent="."]
script = ExtResource( 4 )

[node name="Building" type="TileMap" parent="Map"]
format = 1

[node name="Floor" type="TileMap" parent="Map"]
format = 1

[node name="Terrain" type="TileMap" parent="Map"]
format = 1

[node name="Navigation" type="Navigation2D" parent="."]
script = ExtResource( 2 )

[node name="TileMap" type="TileMap" parent="Navigation"]
visible = false
format = 1
              GDST@   @           9  PNG �PNG

   IHDR   @   @   �iq�   sRGB ���  �IDATx�ݜytTU��?��WK*�=���%�  F����0N��݂:���Q�v��{�[�����E�ӋH���:���B�� YHB*d_*�jyo�(*M�JR!h��S�T��w�߻���ro���� N�\���D�*]��c����z��D�R�[�
5Jg��9E�|JxF׵'�a���Q���BH�~���!����w�A�b
C1�dB�.-�#��ihn�����u��B��1YSB<%�������dA�����C�$+(�����]�BR���Qsu][`
�DV����у�1�G���j�G͕IY! L1�]��� +FS�IY!IP ��|�}��*A��H��R�tQq����D`TW���p\3���M���,�fQ����d��h�m7r�U��f������.��ik�>O�;��xm��'j�u�(o}�����Q�S�-��cBc��d��rI�Ϛ�$I|]�ơ�vJkZ�9>��f����@EuC�~�2�ym�ش��U�\�KAZ4��b�4������;�X婐����@Hg@���o��W�b�x�)����3]j_��V;K����7�u����;o�������;=|��Ŗ}5��0q�$�!?��9�|�5tv�C�sHPTX@t����w�nw��۝�8�=s�p��I}�DZ-̝�ǆ�'�;=����R�PR�ۥu���u��ǻC�sH`��>�p�P ���O3R�������۝�SZ7 �p��o�P!�
��� �l��ހmT�Ƴێ�gA��gm�j����iG���B� ܦ(��cX�}4ۻB��ao��"����� ����G�7���H���æ;,NW?��[��`�r~��w�kl�d4�������YT7�P��5lF�BEc��=<�����?�:]�������G�Μ�{������n�v��%���7�eoݪ��
�QX¬)�JKb����W�[�G ��P$��k�Y:;�����{���a��&�eפ�����O�5,;����yx�b>=fc�* �z��{�fr��7��p���Ôִ�P����t^�]͑�~zs.�3����4��<IG�w�e��e��ih�/ˆ�9�H��f�?����O��.O��;!��]���x�-$E�a1ɜ�u�+7Ȃ�w�md��5���C.��\��X��1?�Nغ/�� ��~��<:k?8��X���!���[���꩓��g��:��E����>��꩓�u��A���	iI4���^v:�^l/;MC��	iI��TM-$�X�;iLH���;iI1�Zm7����P~��G�&g�|BfqV#�M������%��TM��mB�/�)����f����~3m`��������m�Ȉ�Ƽq!cr�pc�8fd���Mۨkl�}P�Л�汻��3p�̤H�>+���1D��i�aۡz�
������Z�Lz|8��.ִQ��v@�1%&���͏�������m���KH�� �p8H�4�9����/*)�aa��g�r�w��F36���(���7�fw����P��&�c����{﹏E7-f�M�).���9��$F�f r �9'1��s2).��G��{���?,�
�G��p�µ�QU�UO�����>��/�g���,�M��5�ʖ�e˃�d����/�M`�=�y=�����f�ӫQU�k'��E�F�+ =΂���
l�&���%%�������F#KY����O7>��;w���l6***B�g)�#W�/�k2�������TJ�'����=!Q@mKYYYdg��$Ib��E�j6�U�,Z�鼌Uvv6YYYԶ��}( ���ߠ#x~�s,X0�����rY��yz�	|r�6l����cN��5ϑ��KBB���5ϡ#xq�7�`=4A�o�xds)�~wO�z�^��m���n�Ds�������e|�0�u��k�ٱ:��RN��w�/!�^�<�ͣ�K1d�F����:�������ˣ����%U�Ą������l{�y����)<�G�y�`}�t��y!��O@� A� Y��sv:K�J��ՎۣQ�܃��T6y�ǯ�Zi
��<�F��1>�	c#�Ǉ��i�L��D�� �u�awe1�e&')�_�Ǝ^V�i߀4�$G�:��r��>h�hݝ������t;)�� &�@zl�Ұր��V6�T�+����0q��L���[t���N&e��Z��ˆ/����(�i啝'i�R�����?:
P].L��S��E�݅�Á�.a6�WjY$F�9P�«����V^7���1Ȓ� �b6�(����0"�k�;�@MC���N�]7 �)Q|s����QfdI���5 ��.f��#1���G���z���>)�N�>�L0T�ۘ5}��Y[�W뿼mj���n���S?�v��ْ|.FE"=�ߑ��q����������p����3�¬8�T�GZ���4ݪ�0�L�Y��jRH��.X�&�v����#�t��7y_#�[�o��V�O����^�����paV�&J�V+V��QY����f+m��(�?/������{�X��:�!:5�G�x���I����HG�%�/�LZ\8/����yLf�Æ>�X�Єǣq���$E������E�Ǣ�����gێ��s�rxO��x孏Q]n���LH����98�i�0==���O$5��o^����>6�a� �*�)?^Ca��yv&���%�5>�n�bŜL:��y�w���/��o�褨A���y,[|=1�VZ�U>,?͑���w��u5d�#�K�b�D�&�:�����l~�S\���[CrTV�$����y��;#�������6�y��3ݸ5��.�V��K���{�,-ւ� k1aB���x���	LL� ����ңl۱������!U��0L�ϴ��O\t$Yi�D�Dm��]|�m���M�3���bT�
�N_����~uiIc��M�DZI���Wgkn����C��!xSv�Pt�F��kڨ��������OKh��L����Z&ip��
ޅ���U�C�[�6��p���;uW8<n'n��nͽQ�
�gԞ�+Z	���{���G�Ĭ� �t�]�p;躆 ��.�ۣ�������^��n�ut�L �W��+ ���hO��^�w�\i� ��:9>3�=��So�2v���U1z��.�^�ߋěN���,���� �f��V�    IEND�B`�           [remap]

importer="texture"
type="StreamTexture"
path="res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.png"
dest_files=[ "res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
              GDSC   %      ;   c     ���Ӷ���   ���Ŷ���   �������ݶ���   ���޶���   ����������ݶ   �������Ŷ���   �������Ҷ���   ��Ķ   ��������϶��   ����   ���ض���   ����   �������������ض�   ��������Ӷ��   �������¶���   �������������Ķ�   ��������������Ķ   ���Ӷ���   ���Ӷ���   ���ٶ���   ���򶶶�   �������Ӷ���   ����������Ķ   �����Ҷ�   ��������������Ŷ   �����������������ݶ�   ����Ӷ��   ���Ӷ���   ��������׶��   ������ض   ��������������¶   ������Ӷ   ���ݶ���   ���������׶�   �����Ҷ�   �����������������ⶶ   �����������Ҷ���                          //        *.pck         //info.json       info.json is missing      Unable to load              .tscn         scene         name      version       version_support        is loaded successfully.       is missing                    	      
                           	      
         !      $      %      &      1      :      E      N      W      ]      h      j      u      x      �      �      �      �      �      �      �       �   !   �   "   �   #   �   $   �   %   �   &   �   '   �   (   �   )   �   *      +     ,     -     .     /     0   $  1   +  2   2  3   @  4   A  5   I  6   L  7   U  8   X  9   ^  :   a  ;   3YY;�  LMYYYY0�  P�  QV�  �  .�  P�  Q�  Y0�  PQV�  .�  �  YY0�  P�  R�  QV�  ;�  �  T�	  PQ�  &�  T�
  P�  Q�  V�  �  T�  P�  R�  Q�  ;�  �  T�  PQ�  *�  �  V�  &�  T�  PQ�  V�  -�  �  P�  �  �  R�  Q�  (V�  &�  T/P�  QV�  &�  T�  PQ�  V�  ;�  �  T�	  PQ�  ;�  �  &P�  T�
  P�  T�  PQ�  �  R�  T�  QQ�  V�  �  �P  P�  T�  PQQ�  (V�  �  T�  P�  Q�  �  &�  T�  P�  T�  PQ�  �  �  QV�  �  T�  P�  �	  �  T�  PQ�  �  R�  Q�  +�  �  ;�  �L  P�  T�  �	  Q�  ;�  N�  �
  V�  R�  �  V�  T�  R�  �  V�  T�  R�  �  V�  T�  �  O�  ;�  �   T�	  PQ�  �  T�!  P�  Q�  �  T�"  P�  Q�  �  T�  P�>  P�  T�  Q�  Q�  �  �  �  T�  PQ�  (V�  �  T�  P�  �  Q�  .�#  �  �  T�$  PQ�  .�  Y`    GDSC      	   '   �      ���ݶ���   ���Ӷ���   ���׶���   ����¶��   �����϶�   �������׶���   ���������׶�   ��������׶��   ������������������϶   ��Ŷ   �����������������ⶶ   ��������������¶   �����������   ���ٶ���   ���ٶ���   ������ض   ���������ﶶ   ��Ŷ   ߶��   ����������Ķ   �����Ҷ�      scene             name      version       version_support                    Unknow type of version_support                                                            	       
   !      '      )      *      0      2      3      4      :      =      >      E      I      J      P      [      ^      g      j      x      {      �       �   !   �   "   �   #   �   $   �   %   �   &   �   '   2Y3�  YY;�  N�  V�  R�  �  V�  R�  �  V�  R�  �  V�  YOYY0�  PQV�  -YY0�  PQV�  -YYY0�  PQV�  .�  �  Y0�  P�  QV�  �  �  �  Y0�  PQV�  &�  T�	  P�  Q�  V�  .�
  �  /�:  P�  T�  QV�  �  V�  .�  T�  T�  T/P�  T�  Q�  �  V�  ;�  �  �  )�  �  T�  V�  &�  T�  T�  T/P�  QV�  �  �  �  .�  �  \V�  �  T�  P�  R�  Q�  .�
  Y`     GDSC             #      ���󶶶�   ����¶��   �����϶�                                     	      
         	      
                                                    !      3YYYYYYYYYY0�  PQV�  -�  Y0�  PQV�  -YYYY`          [remap]

path="res://HUD.gdc"
  [remap]

path="res://HUD/HUD.gdc"
              [remap]

path="res://HUD/Rolling Selection/Rolling Selection.gdc"
              [remap]

path="res://HUD/Rolling Selection/TextureButton.gdc"
  [remap]

path="res://Info.gdc"
 [remap]

path="res://LogRecorder.gdc"
          [remap]

path="res://Main.gdc"
 [remap]

path="res://Test/Test.gdc"
            [remap]

path="res://game_world/Database.gdc"
  [remap]

path="res://game_world/Map.gdc"
       [remap]

path="res://game_world/Navigation.gdc"
[remap]

path="res://game_world/World.gdc"
     [remap]

path="res://pck_loading/PacksManager.gdc"
             [remap]

path="res://pck_loading/pck.gdc"
      [remap]

path="res://script_templates/script_template.gdc"
     �PNG

   IHDR   @   @   �iq�   sRGB ���  �IDATx��ytTU��?�ի%���@ȞY1JZ �iA�i�[P��e��c;�.`Ow+4�>�(}z�EF�Dm�:�h��IHHB�BR!{%�Zߛ?��	U�T�
���:��]~�������-�	Ì�{q*�h$e-
�)��'�d�b(��.�B�6��J�ĩ=;���Cv�j��E~Z��+��CQ�AA�����;�.�	�^P	���ARkUjQ�b�,#;�8�6��P~,� �0�h%*QzE� �"��T��
�=1p:lX�Pd�Y���(:g����kZx ��A���띊3G�Di� !�6����A҆ @�$JkD�$��/�nYE��< Q���<]V�5O!���>2<��f��8�I��8��f:a�|+�/�l9�DEp�-�t]9)C�o��M~�k��tw�r������w��|r�Ξ�	�S�)^� ��c�eg$�vE17ϟ�(�|���Ѧ*����
����^���uD�̴D����h�����R��O�bv�Y����j^�SN֝
������PP���������Y>����&�P��.3+�$��ݷ�����{n����_5c�99�fbסF&�k�mv���bN�T���F���A�9�
(.�'*"��[��c�{ԛmNު8���3�~V� az
�沵�f�sD��&+[���ke3o>r��������T�]����* ���f�~nX�Ȉ���w+�G���F�,U�� D�Դ0赍�!�B�q�c�(
ܱ��f�yT�:��1�� +����C|��-�T��D�M��\|�K�j��<yJ, ����n��1.FZ�d$I0݀8]��Jn_� ���j~����ցV���������1@M�)`F�BM����^x�>
����`��I�˿��wΛ	����W[�����v��E�����u��~��{R�(����3���������y����C��!��nHe�T�Z�����K�P`ǁF´�nH啝���=>id,�>�GW-糓F������m<P8�{o[D����w�Q��=N}�!+�����-�<{[���������w�u�L�����4�����Uc�s��F�륟��c�g�u�s��N��lu���}ן($D��ת8m�Q�V	l�;��(��ڌ���k�
s\��JDIͦOzp��مh����T���IDI���W�Iǧ�X���g��O��a�\:���>����g���%|����i)	�v��]u.�^�:Gk��i)	>��T@k{'	=�������@a�$zZ�;}�󩀒��T�6�Xq&1aWO�,&L�cřT�4P���g[�
p�2��~;� ��Ҭ�29�xri� ��?��)��_��@s[��^�ܴhnɝ4&'
��NanZ4��^Js[ǘ��2���x?Oܷ�$��3�$r����Q��1@�����~��Y�Qܑ�Hjl(}�v�4vSr�iT�1���f������(���A�ᥕ�$� X,�3'�0s����×ƺk~2~'�[�ё�&F�8{2O�y�n�-`^/FPB�?.�N�AO]]�� �n]β[�SR�kN%;>�k��5������]8������=p����Ցh������`}�
�J�8-��ʺ����� �fl˫[8�?E9q�2&������p��<�r�8x� [^݂��2�X��z�V+7N����V@j�A����hl��/+/'5�3�?;9
�(�Ef'Gyҍ���̣�h4RSS� ����������j�Z��jI��x��dE-y�a�X�/�����:��� +k�� �"˖/���+`��],[��UVV4u��P �˻�AA`��)*ZB\\��9lܸ�]{N��礑]6�Hnnqqq-a��Qxy�7�`=8A�Sm&�Q�����u�0hsPz����yJt�[�>�/ޫ�il�����.��ǳ���9��
_
��<s���wT�S������;F����-{k�����T�Z^���z�!t�۰؝^�^*���؝c
���;��7]h^
��PA��+@��gA*+�K��ˌ�)S�1��(Ե��ǯ�h����õ�M�`��p�cC�T")�z�j�w��V��@��D��N�^M\����m�zY��C�Ҙ�I����N�Ϭ��{�9�)����o���C���h�����ʆ.��׏(�ҫ���@�Tf%yZt���wg�4s�]f�q뗣�ǆi�l�⵲3t��I���O��v;Z�g��l��l��kAJѩU^wj�(��������{���)�9�T���KrE�V!�D���aw���x[�I��tZ�0Y �%E�͹���n�G�P�"5FӨ��M�K�!>R���$�.x����h=gϝ�K&@-F��=}�=�����5���s �CFwa���8��u?_����D#���x:R!5&��_�]���*�O��;�)Ȉ�@�g�����ou�Q�v���J�G�6�P�������7��-���	պ^#�C�S��[]3��1���IY��.Ȉ!6\K�:��?9�Ev��S]�l;��?/� ��5�p�X��f�1�;5�S�ye��Ƅ���,Da�>�� O.�AJL(���pL�C5ij޿hBƾ���ڎ�)s��9$D�p���I��e�,ə�+;?�t��v�p�-��&����	V���x���yuo-G&8->�xt�t������Rv��Y�4ZnT�4P]�HA�4�a�T�ǅ1`u\�,���hZ����S������o翿���{�릨ZRq��Y��fat�[����[z9��4�U�V��Anb$Kg������]������8�M0(WeU�H�\n_��¹�C�F�F�}����8d�N��.��]���u�,%Z�F-���E�'����q�L�\������=H�W'�L{�BP0Z���Y�̞���DE��I�N7���c��S���7�Xm�/`�	�+`����X_��KI��^��F\�aD�����~�+M����ㅤ��	SY��/�.�`���:�9Q�c �38K�j�0Y�D�8����W;ܲ�pTt��6P,� Nǵ��Æ�:(���&�N�/ X��i%�?�_P	�n�F�.^�G�E���鬫>?���"@v�2���A~�aԹ_[P, n��N������_rƢ��    IEND�B`�       ECFG      _global_script_classes$                    class         Database      language      GDScript      path      res://game_world/Database.gd      base      Node2D              class         Pack      language      GDScript      path      res://pck_loading/pck.gd      base      Node   _global_script_class_icons4               Database             Pack          application/config/name         Endless Warfare    application/run/main_scene         res://Main.tscn    application/config/icon         res://icon.png     autoload/LogRecorder          *res://LogRecorder.gd      autoload/Info         *res://Info.gd     autoload/GlobalNavigation(         *res://game_world/Navigation.gd    autoload/GlobalWorld$         *res://game_world/World.gd     autoload/PacksManager,      "   *res://pck_loading/PacksManager.gd  )   physics/common/enable_pause_aware_picking         )   rendering/environment/default_environment          res://default_env.tres     