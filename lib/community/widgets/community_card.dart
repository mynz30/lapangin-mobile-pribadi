import 'package:flutter/material.dart';
import 'package:lapangin/community/models/community_models.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback? onTap; // Callback for navigation

  const CommunityCard({super.key, required this.community, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Handle image URL
    // Assuming communityImage might be a full URL or relative path. 
    // If relative, it might need to be prefixed with Base URL, but for now passing as is.
    String imageUrl = community.fields.communityImage;
    if (imageUrl.isEmpty) {
        // Fallback or placeholder
        imageUrl = "https://via.placeholder.com/150"; 
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Image Section
              Container(
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                        // Error handling silently, maybe show a color or icon
                    }
                  ),
                ),
                child: imageUrl.isEmpty ? Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)) : null,
              ),
              
              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            community.fields.communityName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                community.fields.sportsType,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7B904B), // Olive Green
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text("•", style: TextStyle(color: Color(0xFF7B904B), fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Text(
                                  community.fields.location,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC5A027), // Gold
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Description / Join Text
                      Text(
                        community.fields.description.isNotEmpty ? community.fields.description : "Join kuy",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           const Text(
                             "Cek Komunitas \u2192", 
                             style: TextStyle(
                               fontSize: 14,
                               fontWeight: FontWeight.bold,
                               color: Color(0xFF7B904B),
                               decoration: TextDecoration.underline,
                               decorationColor: Color(0xFF7B904B),
                             ),
                           ),
                           Row(
                             children: [
                               const Icon(Icons.person, size: 24, color: Color(0xFF7B904B)),
                               const SizedBox(width: 4),
                               Text(
                                 community.fields.memberCount.toString(),
                                 style: const TextStyle(
                                   fontSize: 18,
                                   fontWeight: FontWeight.bold,
                                   color: Colors.black54,
                                 ),
                               ),
                             ],
                           )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
